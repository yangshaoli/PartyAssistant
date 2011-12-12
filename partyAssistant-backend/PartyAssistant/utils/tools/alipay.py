# -*- coding: utf-8 -*-  
# 
from django.http import HttpResponse
from django.shortcuts import render_to_response
from django.template import RequestContext
from django.contrib.auth import REDIRECT_FIELD_NAME
from django.contrib.auth.decorators import login_required, user_passes_test
from django.template.defaultfilters import urlencode
from django.http import HttpResponseRedirect
from django.conf import settings
from decimal import Decimal, InvalidOperation

import md5, re
import urllib2
from xml.dom.minidom import parseString

class Alipay(object):  
    def __init__(self):  
        self.params = {}  
        # 支付宝gateway   
        self.pay_gate_way = 'https://www.alipay.com/cooperate/gateway.do'  
        # 安全码，在settings文件中 
        self.security_code = settings.ALIPAY_KEY

    #---------------------------------------------------------------------------  
    # 根据订单生成支付宝接口URL  
    # <<<<< Protocol Param >>>>>  
    # @ input_charset: 编码方式  
    # @ service: 接口名称, 有两种方式 =>  
    #            1. trade_create_by_buyer (担保付款)   
    #            2. create_direct_pay_by_user (直接付款)  
    # @ partner : 商户在支付宝的用户ID  
    # @ show_url: 商品展示网址  
    # @ return_url: 交易付款成功后，显示给客户的页面  
    # @ sign_type: 签名方式  
    #  
    # <<<<< Business Param >>>>>  
    # @ subject: 商品标题  
    # @ body: 商品描述  
    # @ out_trade_no: 交易号（确保在本系统中唯一）  
    # @ price: 商品单价  
    # @ discount: 折扣 -**表示抵扣**元  
    # @ quantity: 购买数量  
    # @ payment_type: 支付类型  
    # @ logistics_type: 物流类型 => 1. POST (平邮) 2. EMS 3. EXPRESS (其他快递)  
    # @ logistics_fee: 物流费  
    # @ logistics_payment: 物流支付类型 =>   
    #                      1. SELLER_PAY (卖家支付) 2. BUYER_PAY (买家支付)  
    # @ seller_email: 卖家支付宝帐户email  
    #   
    # @return   
    #---------------------------------------------------------------------------  
    def create_order_alipay_url(self,   
                                input_charset,   
                                service,   
                                partner,   
                                show_url,   
                                return_url,   
                                sign_type,  
                                subject,   
                                body,   
                                out_trade_no,   
                                price,   
                                discount,   
                                quantity,   
                                payment_type,   
                                logistics_type,   
                                logistics_fee,   
                                logistics_payment,   
                                seller_email  
                                ):   
        self.params['_input_charset'] = input_charset  
        self.params['service'] = service  
        self.params['partner'] = partner  
        self.params['show_url'] = show_url  
        self.params['return_url'] = return_url  
        self.params['subject'] = subject  
        self.params['body'] = body  
        self.params['out_trade_no'] = out_trade_no  
        self.params['price'] = price  
        self.params['discount'] = discount  
        self.params['quantity'] = quantity  
        self.params['payment_type'] = payment_type  
        self.params['logistics_type'] = logistics_type  
        self.params['logistics_fee'] = logistics_fee  
        self.params['logistics_payment'] = logistics_payment  
        self.params['seller_email'] = seller_email  
        # 返回结果  
        return self._create_url(self.params, sign_type)  
      
    def conv_uni(self, param, input_charset):
        data = param
        if type(data) is unicode:
            data = data.encode(input_charset)
        return data

    def sign(self, params, sign_type='MD5', input_charset='utf-8'):
        param_keys = []
        sign = ''

        param_keys = params.keys()  
        # 支付宝参数要求按照字母顺序排序  
        param_keys.sort()  
        # 初始化待签名的数据  
        unsigned_data = ''  
        # 生成待签名数据  
        # 注：要求签名数据为urlencoding之前的数据
        for key in param_keys:  
            data = self.conv_uni(params[key], input_charset)
            key = self.conv_uni(key, input_charset)
            unsigned_data += key + '=' + data  
            if key != param_keys[-1]:  
                unsigned_data += '&'  
        # 添加签名密钥  
        unsigned_data += self.security_code  
        # 计算sign值  
        if sign_type == 'MD5':  
            M = md5.new()  
            M.update(unsigned_data)  
            sign = M.hexdigest()  
        else:  
            sign = ''  

        return param_keys, sign

    def _create_url(self, params, sign_type='MD5'):   
        ''' Make sure using unicode or utf-8 as params
        '''
        param_keys, sign = self.sign(params, input_charset=params['_input_charset'])

        request_data = self.pay_gate_way + '?'  
        for key in param_keys:  
            data = params[key]
            if type(data) is unicode:
                data = data.encode(params['_input_charset'])
            request_data += key + '=' + urlencode(data)
            request_data += '&'  
        request_data += 'sign=' + sign + '&sign_type=' + sign_type  
        # 返回结果  
        return request_data  

    def create_direct_pay_by_user_url(self,   
                                      seller_email,
                                      subject,
                                      body,
                                      out_trade_no,
                                      total_fee,
                                      notify_url,
                                      payment_type
                                ):   
        self.params['_input_charset'] = 'utf-8'
        self.params['service'] = 'create_direct_pay_by_user'  

        self.params['partner'] = settings.ALIPAY_PARTNER

        self.params['subject'] = subject  
        if body:
            self.params['body'] = body  
        self.params['out_trade_no'] = out_trade_no  
        self.params['total_fee'] = '%s' % total_fee  
        self.params['notify_url'] = notify_url
        self.params['payment_type'] = payment_type
        self.params['seller_email'] = seller_email  
        # 返回结果  
        return self._create_url(self.params)  

    def validate(self, request):
        '''
        合作伙伴系统需判断接收到的交易状态是否为 TRADE_FINISHED,以及卖家是否同自己系统中的对应。

        1. 支付宝系统向外部系统发出通知,即访问合作伙伴提供的通知接收 URL。
        协议参数
           变量名      类型      说明                                                 可否为空
           notify_type string    trade_status_sync                                    N
           notify_id   string    支付宝通知流水号，查验合法性                         N
           notify_time timestamp YYYY-mm-dd hh:MM:ss
           sign        string    见HTTP参数签名机制                                    N
           sign_type   string    见签名方式                                            N
        业务参数
           变量名       类型        说明                                                 可否为空
           trade_no     stirng(64)  该交易在支付宝系统中的交易流水号                     N
           out_trade_no string(64)  该交易在合作伙伴系统的流水号                         N
           payment_type string      见支付类型枚举表                                     N
           subject      string(256) 商品名称                                             N
           body         string(400) 商品描述                                             Y
           price        Number(13,2)0.01~100000000.00RMB                                 N
           quantity     Number(6,0) >0                                                   N
           total_fee    Number(13,2)0.01~1000000.00RMB                                   N
         交易状态信息
           trade_status string      见交易状态枚举表                                     N
         物流信息
           logistics_type    string      见物流类型枚举表                                   Y
           logistics_fee     Number(8,2) 0.00~10000000.00                                   Y
           logistics_payment string      见物流支付类型枚举表                               Y
           receive_name      string(128) 收货人姓名                                         Y
           receive_address   string(256) 收货人地址                                         Y
           receive_zip       string(6)   收货人邮编                                         Y
           receive_phone     string(30)  收货人电话                                         Y
           receive_mobile    string(11)  收货人手机                                         Y
         买卖双方信息
           seller_email      string(100) 卖家Email                                        N
           seller_id         string(30)  卖家ID                                           N
           buyer_email       string(100) 买家Email                                        N
           buyer_id          string(30)  买家ID                                           N


       支付宝以 POST 方式将上述参数信息发送给合作伙伴设置的 notify_url。


        2. 外部系统接到通知请求,通过 notify_id 询问支付宝这个通知的真实性。
        通知验证接口
        协议参数
           变量名      类型      说明                                                 可否为空
           notify_type string    通知类型，如trade_status_sync，表示交易状态同步通知   N
           notify_id   string    支付宝通知流水号                                      N
           notify_time timestamp 通知时间，格式YYYY-mm-dd hh:MM:ss                     N
           sign        string    见HTTP参数签名机制                                    N
           sign_type   string    见签名方式                                            N
        输入参数
           变量名      类型      说明                                                 可否为空
           service     string    notify_verify                                        N
           partner     string(16)合作伙伴ID                                           N
           notify_id   string    支付宝发送的通知id                                   N
        输出 true/false
        (注，支付宝文档概念名词流程相当乱啊(-_-!)
        验证接口URL
           https://www.alipay.com/cooperate/gateway.do
           http://notify.alipay.com/trade/notify_query.do
        例子：
           https://www.alipay.com/cooperate/gateway.do?service=notify_verify&partner=1234567890&notify_id=abcdefghijklmnopqrst
           http://notify.alipay.com/trade/notify_query.do?msg_id=24e596197be0dc9367502c3d598cd513&email=merchanttool@alipay.com&order_no=30944292
        Note:
            1. query in 1 minutes
            2. validate is your duty


        3. 支付宝系统判断通知是否是自己发送,如果是返回 true,否则返回 false。

        4. 商户系统得到支付宝系统的确认后,对通知进行处理。处理完毕后,返回结果给支付宝系统,处理结果的值见通知返回结果枚举表。
        5. 支付宝系统处理商户系统返回的处理结果。
        '''
        valid = False
        infos = {}

        # Log infos
        # Note: Make sure touch alipay_nofify.log and chmod 666
        request_uid = 'airenao.log'
        file = open(request_uid,'a')  
        # Http request  
        text = '-' * 80  
        text += '\n%s %s (%s at %s)' % (request.is_secure() and 'HTTPS' or 'HTTP', request.path, request.META.get('REMOTE_ADDR'), datetime.now())  
        text += '\nMETA'
        for k, v in request.META.items():
            if k.startswith('HTTP') or k.startswith('REMOTE') or k.startswith('QUERY') or k.startswith('CONTENT'):
                text += '\n %s: %s' % (k, v)
        text += '\nINFO'
        text += '\n Session ID: %s' % request.COOKIES.get('sessionid')  
        text += '\n Parameters: [%s] %s %s' % (request.method, request.raw_post_data, request.META.get('QUERY_STRING'))  
            
        print >> file, text      

        if request.method == 'POST':
            data_dict = request.POST
            sign_type = data_dict.get('sign_type', '').lower()
            if sign_type == 'md5':
                sign = data_dict.get('sign', '')
                params = {}
                for k, v in data_dict.items():
                    if k not in ('sign', 'sign_type'):
                        params[k] = v

                # 签名比较防篡改
                keys, our_sign = self.sign(params)
                if sign == our_sign:
                    # 验证notify_id
                    notify_id = params['notify_id']
                    notify_verify_url = self.create_notify_verify_url(notify_id)
                    print >> file, '='*80
                    print >> file, 'Verify: ' + notify_verify_url

                    req = urllib2.Request(notify_verify_url)
                    fd = urllib2.urlopen(req, {})
                    rsp = fd.read()
                    if rsp == 'true':
                        valid = True
                        infos = params
                        print >> file, 'true'
                    elif rsp == 'false':
                        pass
                        print >> file, 'false'
                    else:
                        # Assume GBK encoding
                        lines = rsp.split('\n')
                        first_line = lines[0]
                        m = re.search(r'encoding="(\S+)"', first_line)
                        if m:
                            enc = m.group(1)
                        else:
                            enc = 'gbk'
                        rsp = rsp.decode(enc).encode('utf-8')
                        dom = parseString(lines[1])
                        rsp_xml = dom.toprettyxml()
                        print >> file, rsp_xml
                        root = dom.documentElement
                        def get_text(node):
                            return "".join(t.nodeValue for t in node.childNodes if t.nodeType == t.TEXT_NODE)
                        is_success = get_text(root.getElementsByTagName('is_success')[0])
                        error = get_text(root.getElementsByTagName('error')[0])

                        #print is_success, error

        file.close()  
        return valid, infos

    def create_notify_verify_url(self, notify_id):
        request_data = self.pay_gate_way + '?service=notify_verify'  
        request_data += '&partner=' + settings.ALIPAY_PARTNER
        request_data += '&notify_id=' + notify_id
        return request_data


    # 支付类型枚举表
    payment_types = {
        '1':'商品购买',
        '2':'服务购买',
        '3':'网络拍卖',
        '4':'捐赠',
        '5':'邮费补偿',
        '6':'奖金',
    }
    # 交易动作枚举表
    actions = {
        # 买家动作
        'PAY':'付款',
        'REFUND':'退款',
        'CONFIRM_GOODS':'确认收货',
        'CANCEL_FAST_PAY':'付款方取消快速支付',
        'WAIT_BUYER_CONFIRM_GOODS':'快速支付付款',
        'FP_PAY':'买家确认收到货，等待支付宝打款给卖家',
        'RM_PAY':'催款中还钱',
        'MODIFY_DELIVER_ADDRESS':'买家修改收货地址',
        # 卖家动作
        'SEND_GOODS':'发货',
        'REFUSE_TRADE':'拒绝交易',
        'MODIFY_TRADE':'修改交易',
        'REFUSE_FAST_PAY':'收款方拒绝付款',
        # 共有动作
        'QUERY_LOGISTICS':'查看物流状态',
        'QUERY_REFUND':'查看退款状态',
        'EXTEND_TIMEOUT':'延长对方超时时间',
        'VIEW_DETAIL':'查看明细',
    }
    # 交易状态枚举表
    trade_statuses = {
        'WAIT_BUYER_PAY':'等待买家付款',
        'WAIT_SELLER_CONFIRM_TRADE':'交易已创建，等待卖家确认',
        'WAIT_SYS_CONFIRM_PAY':'确认买家付款中，暂勿发货',
        'WAIT_SELLER_SEND_GOODS':'支付宝收到买家付款，请卖家发货',
        'WAIT_BUYER_CONFIRM_GOODS':'卖家已发货，买家确认中',
        'WAIT_SYS_PAY_SELLER':'买家确认收到货，等待支付宝打款给卖家',
        'TRADE_FINISHED':'交易成功结束',
        'TRADE_CLOSED':'交易中途关闭（未完成）',
    }
    # 物流状态枚举表
    trade_statuses = {
        'INITIAL_STATUS':'初始状态',
        'WAIT_LOGISTICS_FETCH_GOODS':'等待物流取货',
        'WAIT_LOGISTICS_SEND_GOODS':'等待物流发货',
        'LOGISTICS_SENDING':'物流发货中',
        'WAIT_RECEIVER_CONFIRM_GOODS':'等待收货人确认收货',
        'GOODS_RECEIVED':'货物收到了',
        'LOGISTICS_FAILURE':'物流失败',
    }
    # 退款状态枚举表
    refund_statuses = {
        'WAIT_SELLER_AGREE':'等待卖家同意退款',
        'SELLER_REFUSE_BUYER':'卖家拒绝买家条件，等待买家修改条件',
        'WAIT_BUYER_RETURN_GOODS':'卖家同意退款，等待买家退货',
        'WAIT_SELLER_CONFIRM_GOODS':'等待卖家收货',
        'WAIT_ALIPAY_REFUND':'对方已经一致，等待支付宝退款',
        'ALIPAY_CHECK':'支付宝处理中',
        'OVERED_REFUND':'结束的退款',
        'REFUND_SUCCESS':'退款成功',
        'REFUND_CLOSED':'退款关闭',
    }
    # 物流类型枚举表
    logistics_types = {
        'VIRTUAL':'虚拟物品',
        'POST':'平邮',
        'EMS':'EMS',
        'EXPRESS':'其他快递公司',
    }
    # 物流支付方式枚举表
    logistics_payments = {
        'SELLER_PAY':'卖家支付', # 由卖家支付物流费用（费用不用计算到总价内）
        'BUYER_PAY':'买家支付', # 由买家支付物流费用（费用需要计算到总价内）
        'BUYER_PAY_AFTER_RECEIVE':'货到付款', # 买家收到货物后直接支付给物流公司（费用不用计算到总价内）
    }
      
@login_required
def pay(request):
    request_url = '/accounts/profile'
    if request.method == 'POST':
        seller_email = settings.ALIPAY_SELLER_EMAIL;
        subject = request.POST.get('subject', '')
        body = request.POST.get('body', '')
        out_trade_no = request.POST.get('out_trade_no', '')
        price = request.POST.get('price', '')

        # Maybe security problem here
        notify_url = request.POST.get('notify_url', '')

        payment_type = request.POST.get('payment_type', '')
        try:
            total_fee = Decimal(price)
        except InvalidOperation:
            total_fee = None
        if seller_email and subject and out_trade_no and total_fee and notify_url and payment_type:
            user = request.user
            alipay = Alipay()
            request_url = alipay.create_direct_pay_by_user_url(seller_email, subject, body, out_trade_no, total_fee, notify_url, payment_type)
    return HttpResponseRedirect(request_url)