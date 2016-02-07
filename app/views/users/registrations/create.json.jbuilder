json.success @success
json.data do
  if @success
    json.token @user.authentication_token
  else
    json.errors @errors if not @errors.blank?
  end
end
