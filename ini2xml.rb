#encoding: utf-8
require 'inifile'
require 'xmlsimple'
require 'Find'
require 'builder'

xpadder_keyCode = IniFile.load("./Inis/keycode_xpadder.ini")
gamepad_tv =  IniFile.load("./Inis/gamepad_tv.ini")

keycode_hsh = xpadder_keyCode["keycode"]
gamepad_hsh = gamepad_tv["key pairs"]


#这里可能会有bug，应该是根据文件后缀来判断，需要修改一下。
def scanf(path)
  list=[]
  Find.find(path) do |f|
    if File.ftype(f) == "file"
    list << f
    end
  end
  list.sort
end

def mergeHash(gamepad_hsh,keycode_hsh,xpadder_hsh)
  return gamepad_hsh.inject({}) { |h, e| h[e.first] = keycode_hsh[xpadder_hsh[e.last]]; h }
end

def creatfinalxml(final_hsh)
  builder = Builder::XmlMarkup.new(:target => @stdout, :indent => 1)
  builder.set do
    builder.hash_code("value" => "")    
    builder.enable_multiJoy("value" =>"") 
    builder.enable_fn("value" => "")
    builder.key do
      final_hsh.each do |k,v|
        builder.method_missing(k,"value" => v)
        builder.method_missing(k+"_act","value" => "")
      end
    end
    builder.mouse do
      builder.enable("value" => 1)
      builder.move("value" => 0)
      builder.mouse_sensitive("value" => 2000)
      builder.left("value" => 10)
      builder.right("value" => 11)
    end
  end
  builder
end

#下面开始执行调用
final_obj = Hash.new
files = scanf("./Xpadderinis")
p files
files.each do |f|
  file_name = File.basename(f,".xpadderprofile")
  xpadder = IniFile.load(f)
  xpadder_hsh = xpadder["Assignments"]
  final_obj = mergeHash(gamepad_hsh,keycode_hsh,xpadder_hsh)
  p file_name
  final_xml = creatfinalxml(final_obj)
  File.open("./Xmls/#{file_name}.xml","w") do |xml_file|
    xml_file << final_xml
  end
end

