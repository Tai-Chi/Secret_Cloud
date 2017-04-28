class JsonParser
  def self.call(request, *args)
    list = []
    request_body = JSON.parse(request.body.read)
    args.each do |item|
      list.push(request_body[item])
    end
    return list
  end
end
