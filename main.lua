if not native.canShowPopup("mail") then
  native.showAlert("No e-mail detected", "You will not be able e-mail data from this device without a working e-mail client installed. Check that an e-mail account is set up correctly by opening Settings > Accounts &  Passwords. Apple provide free icloud e-mails you can use for this purpose. You can still access data using iTunes File Sharing if you connect this device to a computer with iTunes installed.",{"Ok"})
end

local composer=require "composer"
composer.gotoScene("scenes.setuser")