module FiLabApp
    module UserHelper
#   extend FiLabApp::UserHelper
    
    def user_role(current_user,role_name)
      value = false;
      current_user.fi_lab_app_roles.each do |role|
	if role.name == role_name
	  value=true
	end
      end
      value
    end
    
    def user_logged(current_user)
      value = (current_user != nil);
      value
    end
  end
end
