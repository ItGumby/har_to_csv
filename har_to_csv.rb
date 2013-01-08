require 'json'
raise Exception, 'you must provide a json file' unless ARGV[0]

SEP = "\t"

def header_to_csv(data)
  header = []
  header << ""
  data.first.each_pair do |ek,ev| # data.first.class => Hash
    header << ek.to_s and next if ev.class != Hash
    ev.reject{|k,v| k == 'headers' || k == 'cookies'}.each_pair do |k,v|
      if v.class != Hash
        header << k.to_s
      else
        v.each_pair do |k2,v2| # content
          header << k2.to_s
        end
      end
    end
  end
  puts header.join(SEP)
end

def data_to_csv(data)
  data.each_with_index do |entry,i| # data.class => Array
    csv = []
    csv << (i+1).to_s
    entry.each_pair do |ek,ev| # entry.class => Hash
      csv << ev.to_s and next if ev.class != Hash
      ev.reject{|k,v| k == 'headers' || k == 'cookies'}.each_pair do |k,v|
        if v.class != Hash
          csv << v.to_s
        else
          v.each_pair do |k2,v2| # content
            csv << v2.to_s
          end
        end
      end
    end
    puts csv.join(SEP)
  end
end

def output_entries(entries)
  entries.each_with_index do |entry,i| # l2v.class => Array
    puts " "*3 + "entries:" + i.to_s
    entry.each_pair do |l4k,l4v| # entry.class => Hash
      if l4v.class != Hash
        puts " "*4 + l4k + ":" + l4v.to_s
      else
        puts " "*4 + l4k + ":"
        l4v.each_pair do |l5k,l5v|
          if l5v.class == Hash
            l5v.each_pair do |l6k,l6v|
              puts " "*5 + l6k + ":" + l6v.to_s
            end
          elsif l5v.class == Array
            l5v.each_with_index do |l6v,i6|
              if l6v.class == Hash
                puts " "*5 + l5k + ":" + i6.to_s
                l6v.each_pair do |l7k,l7v|
                  puts " "*6 + l7k + ":" + l7v.to_s
                end
              else
                puts " "*5 + l5k + ":" + i6.to_s + ":" + l6v.to_s
              end
            end
          else
            puts " "*5 + l5k + ":" + l5v.to_s
          end
        end
      end
    end
  end
end

def output_json_text(json)
  json.each_pair do |l1k,l1v|
    puts l1k + ":" + "#{l1v.length}"
    l1v.each_pair do |l2k,l2v| # l1v.class => Hash
      puts " " + l2k + ":" + "#{l2v.length}"
      if l2v.class == Hash
        l2v.each_pair do |l3k,l3v|
          puts " "*2 + l3k + ":" + l3v.to_s
        end
      elsif l2v.class == Array # entries
        output_entries l2v
      else
        puts " "*2 + l2k + ":" + l2v.to_s
      end
    end
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
        header_to_csv(l2v)
        data_to_csv(l2v)
      else
        puts " "*2 + l2k + ":" + l2v.to_s
      end
    end
  end
end

json = JSON.parse(File.open(ARGV[0]).read)
output_json_csv json
