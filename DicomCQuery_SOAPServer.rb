require 'rubygems'
require 'soap/rpc/standaloneServer'
require "win32ole"


#setting application
$apppath="D:\\DicomCQuery_SOAPServer\\"
$appname="movescu.exe"
$mode="-d -v"
$aetitle="--aetitle minipacstest"
$call="--call TCGHWFM01"
$querylevel="--study"
$queryresultlevel="-k 0008,0052=STUDY"
$ip="10.10.5.2"
$port="104"


#create shell ole object
$shell=WIN32OLE.new("shell.application")


class DicomCQuery_SOAPServer < SOAP::RPC::StandaloneServer
  def initialize(*args)
    super
    add_method(self,'movescu','patientid','accessionno')
  end
end

class DicomCQuery_SOAPServer
  def movescu(patientid,accessionno)
    begin
      #call movescu to Dicom C-Query
      $shell.ShellExecute("#{$apppath}#{$appname}","#{$mode} #{$aetitle} #{$call} #{$querylevel} #{$queryresultlevel} -k 0010,0020=#{patientid} -k 0008,0050=#{accessionno} #{$ip} #{$port}")
      
      #response for client
      "#{accessionno}:CQuery成功."
    rescue
      #response for client
      "#{accessionno}:CQuery失敗."
    ensure
      #make log
      ymd=Date.today.strftime("%Y%m%d")
      hms=Time.now.strftime("%H%M%S")

      fout=File.open("#{ymd}.log","a+")
      fout.write("#{hms}:#{patientid}:#{accessionno}.\n")
      fout.close()
    end
  end
end


server=DicomCQuery_SOAPServer.new('SamewaySOAPServer','urn:SamewaySOAPServer','10.10.5.60',8888)
trap('INT'){server.shutdown}
server.start