class CreateFileinfo
  def self.call(fileattr)
    fileinfo = Fileinfo.new(name_secure: fileattr[:name], parent_id: fileattr[:parent_id], account_id: fileattr[:account_id], portion: fileattr[:portion], gaccount_id: fileattr[:gaccount_id], gfid_secure: fileattr[:gfid], size: fileattr[:size])
    fileinfo.name = fileattr[:name]
    fileinfo.gfid = fileattr[:gfid]
    fileinfo.save
  end
end
