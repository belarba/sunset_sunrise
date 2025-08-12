json.extract! @error, :status, :error, :message
json.timestamp Time.current.iso8601
json.request_id request.uuid if request.respond_to?(:uuid)
