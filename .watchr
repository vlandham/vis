watch ( 'coffee/(.*)\.coffee' ) { |md| system("coffee -o #{File.dirname(md[0])} -c #{md[0]}") }
