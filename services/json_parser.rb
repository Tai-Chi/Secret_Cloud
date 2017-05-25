class JsonParser
  def self.call(request, *args)
    list = []
    request_body = JSON.parse(request.body.read)
    args.each do |item|
      list.push(request_body[item])
    end
    if list.size() <= 0
      return nil
    elsif list.size() == 1
      return list[0]
    else
      return list
    end
  end
end
