$(document).ready(function(){
	$('.TimePker').each(function(){
		new TimePker(this);
		
	})
})
function TimePker(o){
	this.id = o.id;
	this.value = o.style;
	this._initHtml();
	this.bindEvent();
}
/* 初始化下拉框的html代码 */
TimePker.prototype._initHtml=function(){
	var hc='';
	for(i=0;i<24;i++){
		if(i<10){
			hc +='<div><a href="#">'+ '0'+ i +':00</a></div>';
			hc +='<div><a href="#">'+ '0'+ i +':30</a></div>';
		}else{
			hc +='<div><a href="#">'+ i +':00</a></div>';
			hc +='<div><a href="#">'+ i +':30</a></div>';
		}
	}
	hc='<div id="tslt_'+ this.id +'" class="time_class">'+hc+'</div>';
	$(hc).appendTo("body");
}

TimePker.prototype.bindEvent = function(){
	ele = document.getElementById(this.id);
	/* 为输入框加入焦点事件——显示时间插件 */
	var h = ele.offsetHeight; // 输入框的高
	var slt_h = parseInt($('.time_class div').css('height'),10);    //时间div的高
	$(ele).bind('focus', function(){
		var top = $(this).offset().top + h;
		var left = $(this).offset().left;
		$('#tslt_' + this.id).css('top', top);
		$('#tslt_' + this.id).css('left', left);
		$('#tslt_' + this.id).fadeIn(200);
		f(this,slt_h)
	});
	/* 为输入框加入失去焦点事件——隐藏时间插件 */
	$(ele).bind('blur', function(e){
		$('#tslt_' + this.id).fadeOut(200);
	});
	/* 为输入框加入输入监听事件——时间随输入变化 */
	$(ele).bind('keyup', function(e){
		f(this, slt_h);
	});
	/* 为时间插件加入点击事件——插入时间 */
	$('.time_class a').each(function(){
		$(this).bind('click', function(){
			var v = $(this).text();
			var id = $(this).parent().parent().attr('id');
			$('#' + id.substring(5, id.length)).val(v);
			return false
		});
	});
	//根据输入值滚动时间插件的函数
	f = function(ele, h){
		var x = 8, y = 0;
		var v = ele.value;
		if (v) {
			typeof(v) != 'String' ? v.toString() : v;
			l = v.split(':');
			if (l.length == 2 && l[0] >= 0 && l[0] <= 23) {
				x = parseInt(l[0], 10);
				if (l[1] >= 30 && l[1] <= 59) 
					y = 1;
				else 
					y = 0;
			}
			else 
				if (l.length == 1 && l[0] >= 0 && l[0] <= 23) {
					x = parseInt(l[0], 10);
				}
		}
		$('#tslt_' + ele.id).animate({
			scrollTop: (2 * x + y) * h
		}, 50);
	}
}
