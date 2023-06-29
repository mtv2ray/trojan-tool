import sys
# Define the port number
PORT = 80
if sys.version_info.major == 3:
   from http.server import BaseHTTPRequestHandler, HTTPServer
   import ssl

   class MyHandler(BaseHTTPRequestHandler):
      def do_GET(self):
         self.send_response(200)
         self.send_header('Content-type', 'text/plain')
         self.end_headers()
         self.wfile.write(b'Hello')

   if __name__ == '__main__':
      server_address = ('', PORT)
      httpd = HTTPServer(server_address, MyHandler)
      context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
      print('Python3 Server running on port',PORT)
      httpd.serve_forever()
if sys.version_info.major == 2:
   import SimpleHTTPServer
   import SocketServer


   # Create a request handler class by extending SimpleHTTPServer.SimpleHTTPRequestHandler
   class MyRequestHandler(SimpleHTTPServer.SimpleHTTPRequestHandler):
      # Override the do_GET method to customize the response
      def do_GET(self):
         # Set the response status code
         self.send_response(200)
         # Set the response headers
         self.send_header('Content-type', 'text/plain')
         self.end_headers()
         # Send the response content
         self.wfile.write('Hello')

   # Create a socket server with the defined port and request handler
   httpd = SocketServer.TCPServer(("", PORT), MyRequestHandler)

   # Start the server
   print("Python2 Server running on port", PORT)
   httpd.serve_forever()
    