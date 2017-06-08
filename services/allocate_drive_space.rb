class AllocateDriveSpace
  def self.call(account, size)
    gaccounts = account.gaccounts
    gaccounts.each do |gaccount|
      if size <= gaccount.size
        gaccount.size -= size
        return gaccount
      end
    end
    nil
  end
end
