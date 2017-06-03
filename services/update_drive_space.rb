class UpdateDriveSpace
  def self.call(name, size)
    table = DB[:gaccounts]
    table.each do |gaccount|
      gaccount = Gaccount[gaccount[:id]]
      if name == gaccount.name
        gaccount[:size] = size
        gaccount.save
        return true
      end
    end
    false
  end
end