'''
Created on 2011-10-27

@author: liwenjian
'''
class VariantTemplateMiddleware():
    def process_template_response(self, request, response):
        template_name_list = response.template_name
        if type(template_name_list) == str:
            template_name_list = [template_name_list]
        
        if request.path.startswith('/a/'):
            a_template_name_list = ['a/%s' % t for t in template_name_list]
            a_template_name_list.extend(template_name_list)
            response.template_name = a_template_name_list
        
        if request.path.startswith('/m/'):
            m_template_name_list = ['m/%s' % t for t in template_name_list]
            m_template_name_list.extend(template_name_list)
            response.template_name = m_template_name_list

        return response
