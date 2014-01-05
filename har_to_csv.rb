require 'rubygems'
require 'json'
raise Exception, 'you must provide a json file' unless ARGV[0]

SEP = "\t"
ENTRY_FORMAT = ["request", "response", "timings", "startedDateTime", "time"]
REQUEST_FORMAT = ["method", "url", "httpVersion", "queryString", "headersSize", "bodySize"]
RESPONSE_FORMAT = [ "status", "statusText", "httpVersion", "content", "redirectURL", "headersSize", "bodySize"]
CONTENT_FORMAT = [ "size", "mimeType", "compression"]
TIMING_FORMAT = [ "blocked", "dns", "connect", "send", "wait", "receive", "ssl"]

=begin
entries structure
Array
=> {
     startedDateTime,
     time,
     request
     => {
          method,
          url,
          httpVersion,
          headers
          => Array
            => {},
          queryString,
          cookies
          => Array
            => {},
          headersSize,
          bodySize
        },
     response
     => {
          status,
          statusText,
          httpVersion,
          headers
          => Array
            => {},
          cookies
          => Array
            => {},
          content
          => {
              size,
              mimeType,
              compression
             },
          redirectURL,
          headersSize,
          bodySize
        },
     cache
     => {
        },
     timings
     => {
          blocked,
          dns,
          connect,
          send,
          wait,
          receive,
          ssl
        },
     pageref
   }
=end

def pages_to_csv(pages)
  # header
  header = []
  header << ""
  pages.first.each_pair do |k,v|
    if v.class != Hash
      header << k.to_s
    else
      v.each_pair do |k2,v2|
        header << k2.to_s
      end
    end
  end
  puts header.join(SEP)

  # data
  pages.each_with_index do |page,i|
    csv = []
    csv << (i+1).to_s
    page.each_pair do |k,v|
      if v.class != Hash
        csv << v.to_s
      else
        v.each_pair do |k2,v2|
          csv << v2.to_s
        end
      end
    end
    puts csv.join(SEP)
  end
end

def entries_header_to_csv
  header = []
  header << ""
  # request
  REQUEST_FORMAT.each do |k|
    header << k.to_s
  end
  # response
  RESPONSE_FORMAT.reject{|k| k == 'content'}.each do |k|
    header << k.to_s
  end
  CONTENT_FORMAT.each do |k|
    header << k.to_s
  end
  # timings
  TIMING_FORMAT.each do |k|
    header << k.to_s
  end
  # other
  header << "startedDateTime"
  header << "time"
  puts header.join(SEP)
end

def entries_data_to_csv(data)
  data.each_with_index do |entry,i| # data.class => Array
    csv = []
    csv << (i+1).to_s
    # request
    request = entry["request"]
    REQUEST_FORMAT.each do |k|
      csv << request[k].to_s
    end
    # response
    response = entry["response"]
    RESPONSE_FORMAT.reject{|k| k == 'content'}.each do |k|
      csv << response[k].to_s
    end
    content = response['content']
    CONTENT_FORMAT.each do |k|
      csv << content[k].to_s
    end
    # timings
    timings = entry["timings"]
    TIMING_FORMAT.each do |k|
      csv << timings[k].to_s
    end
    # other
    csv << entry["startedDateTime"].to_s
    csv << entry["time"].to_s

    puts csv.join(SEP)
  end
end

def output_json_csv(json)
  json.each_pair do |l1k,l1v|
    puts l1k + ":"
    l1v.each_pair do |l2k,l2v| # l1v.class => Hash
      puts " " + l2k + ":"
      if l2v.class == Hash
        l2v.each_pair do |l3k,l3v|
          puts " "*2 + l3k + ":" + l3v.to_s
        end
      elsif l2v.class == Array # pages,entries
        if l2k == 'entries'
          entries_header_to_csv
          entries_data_to_csv(l2v)
        elsif l2k == 'pages'
          pages_to_csv(l2v)
        end
      else
        puts " "*2 + l2k + ":" + l2v.to_s
      end
    end
  end
end

json = JSON.parse(File.open(ARGV[0]).read)
output_json_csv json
