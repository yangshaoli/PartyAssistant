from django.shortcuts import redirect, render_to_response
from django.contrib.auth.decorators import login_required
from django.template.context import RequestContext
from django.views.decorators.csrf import csrf_exempt
from django.contrib.auth.decorators import login_required
from django.contrib.auth import logout
from django.contrib.auth.models import User

from accounts.forms import RegisterForm

def register(request):
    if request.method == 'POST':
        form = RegisterForm(request.POST)
        if form.is_valid():
            user = User.objects.create_user(
                form.cleaned_data['username'],
                form.cleaned_data['email'],
                form.cleaned_data['password'],
            )
            user.is_staff = True
            user.save()
            return redirect ('/accounts/login/?next=/')
        else:
            error_form = RegisterForm(initial={
                'username':request.POST['username'],
                'email':request.POST['email']
            })
            ctx = {
                'form'  : error_form,
                'error' : form.errors,
            }
            return render_to_response('accounts/register.html', ctx , context_instance = RequestContext(request))
    else:
	    return render_to_response('accounts/register.html',{'form' : RegisterForm()}, context_instance = RequestContext(request))

