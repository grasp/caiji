# To change this template, choose Tools | Templates
# and open the template in the editor.
module EmailHelper
def clear_nil_address_email
  Email.where(:address=>nil).each do |email|
    email.delete
  end
end
end



