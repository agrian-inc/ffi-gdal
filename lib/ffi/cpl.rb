# typed: strict
# frozen_string_literal: true

module FFI
  module CPL
    autoload :Conv, File.expand_path('cpl/conv.rb', __dir__)
    autoload :Error, File.expand_path('cpl/error.rb', __dir__)
    autoload :HashSet, File.expand_path('cpl/hash_set.rb', __dir__)
    autoload :HTTP, File.expand_path('cpl/http.rb', __dir__)
    autoload :MiniXML, File.expand_path('cpl/minixml.rb', __dir__)
    autoload :Port, File.expand_path('cpl/port.rb', __dir__)
    autoload :Progress, File.expand_path('cpl/progress.rb', __dir__)
    autoload :QuadTree, File.expand_path('cpl/quad_tree.rb', __dir__)
    autoload :String, File.expand_path('cpl/string.rb', __dir__)
    autoload :VSI, File.expand_path('cpl/vsi.rb', __dir__)
    autoload :XMLNode, File.expand_path('cpl/xml_node.rb', __dir__)
  end
end
