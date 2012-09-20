#encoding: utf-8
require 'inifile'
require 'builder'

#下面导入的部分是常量，读入基础配置信息
Xpadder_keycode = IniFile.load("./Inis/keycode_xpadder.ini")
Gamepad_tv =  IniFile.load("./Inis/gamepad_tv.ini")

Keycode_hsh = Xpadder_keycode["keycode"]
Gamepad_hsh = Gamepad_tv["key pairs"]

#合并生成
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
        builder.method_missing(k+"_fn", "value" =>"")
        builder.method_missing(k+"_act","value" => "")
        builder.method_missing(k+"_fn_act","value" => "")
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
Dir.foreach("./Xpadderinis") do |filename|
  if File.extname(filename) == ".xpadderprofile"
    xpadder = IniFile.load(filename)
    xpadder_hsh = xpadder["Assignments"]
    final_obj = mergeHash(Gamepad_hsh, Keycode_hsh, xpadder_hsh)
    final_xml = creatfinalxml(final_obj)
    File.open("./Xmls/#{File.basename("#{filename}", ".xpadderprofile")}.xml", "w") { |xml_file| xml_file << final_xml }
  end
end
