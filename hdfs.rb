require 'rubygems'
require 'sinatra'
require 'json/pure'
require 'webhdfs'

get '/' do
  res = '<html><body style="margin:0px auto; width:80%; font-family:monospace">'
  res << '<head><title>Cloud Foundry HDFS demo app</title><meta name="viewport" content="width=device-width"></head>'
  res << '<h2>Cloud Foundry HDFS demo app</h2>'
  res << "<p>Application binded to service <strong>#{dfs_service['name']}</strong> on plan <strong>#{dfs_service['plan']}</strong></p>"
  res << '<div><table>'
  res << "<tr><th>Filename</th><th>Length</th><th>Owner</th><th>Permission</th></tr>"
  files = dfs_client.list(dfs_path)
  if files.empty?
    res << '<tr><td colspan=3>No available files</td></tr>'
  else
    files.each do |file|
      res << "<tr>"
      res << "<td><strong>#{file['pathSuffix']}</strong></td>"
      res << "<td>#{file['length']}</td>"
      res << "<td>#{file['owner']}</td>"
      res << "<td>#{file['permission']}</td>"
      res << "</tr>"
    end
  end
  res << '</table></div>'
  res << '<p><strong>Credentials</strong>:</p>'
  res << '<ul>'
  dfs_credentials.each_pair do |k,v|
    res << "<li>#{k}: #{v}</li>"
  end
  res << '</ul>'
  res << '</body></html>'
end

private

def dfs_client
  WebHDFS::Client.new(dfs_host, dfs_port, dfs_username)
end

def services
  JSON.parse(ENV['VCAP_SERVICES'])
end

def dfs_service
  services['hdfs'].first
end

def dfs_credentials
  dfs_service['credentials']
end

def dfs_host
  dfs_credentials['host']
end

def dfs_port
  dfs_credentials['port']
end

def dfs_username
  dfs_credentials['username']
end

def dfs_path
  dfs_credentials['path']
end

