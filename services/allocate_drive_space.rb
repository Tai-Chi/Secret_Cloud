class AllocateDriveSpace
  def self.call(size)
    table = DB[:gaccounts]
    table.each do |gaccount|
      gaccount = Gaccount[gaccount[:id]]
      if size <= gaccount[:size]
        gaccount[:size] -= size
        return gaccount
      end
    end
    nil
  end
end