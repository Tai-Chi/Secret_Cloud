class SplitPath
  def self.call(path, go_to_last_folder=false)
    pathUnits = path.split(/[\\\/]/)
    pathUnits.select! { |unit| !unit.empty? }
    if go_to_last_folder
      fName = pathUnits.pop
      return pathUnits, fName
    else
      return pathUnits
    end
  end
end
