class Radiant::Route < Radiant::Model

  # A description for the route type
  annotate :description

  # Acts as Tree
  acts_as_tree :order => 'title ASC'

  # Validations
  validates_presence_of :title, :slug
  validates_format_of :slug, :with => %r{^([-_.A-Za-z0-9]*|/)$}
  validates_uniqueness_of :slug, :scope => :parent_id
  validates_uniqueness_of :path

  # Don't allow path to be set from params
  attr_protected :path
  
  # Use "class_name" for inheritance column
  set_inheritance_column :class_name

  # Calculate main content for a route. By default this method returns
  # an empty string, but this should be overridden in decendants or extensions
  # to produce the actual content for the route if needed.
  def body
    ''
  end

  # Calculates breadcrumb for route. If one does not exist, use title.
  def breadcrumb
    attributes['breadcrumb'] || title
  end

  # Calculate the headers for the current route 
  def headers
    { } # Return a blank hash that child classes can override or merge
  end

  # Calculate the path for a child of the route. This hook allows the
  # parent to determine the paths of the children.
  def child_path(child)
    normalize_path(path + '/' + child.slug)
  end

  # Returns true if this route has a parent in the tree.
  def parent?
    !parent.nil?
  end

  # Process the request and response. Used by the PageController.
  def process(request, response)
    @request, @response = request, response
    headers.each { |k,v| @response.headers[k] = v }
    @response.body = render
    @response.status = response_code
  end

  # Response code for route 
  def response_code
    200 # OK
  end

  # Render the text for the body of the response
  def render
    body
  end

  ##
  ## Callbacks
  ##

  # Calculate the path for route
  def calculate_path
    if parent?
      self.path = parent.child_path(self)
    else
      self.path = normalize_path(slug)
    end
  end
  before_save :calculate_path
  
  # After saving, recalculate the paths of all of the route's children
  def recalculate_child_paths
    children.each(&:save!) if children.count > 0
  end
  after_save :recalculate_child_paths

  private

    # Remove extra slashes from path
    def normalize_path(path)
      self.class.normalize_path(path)
    end

  module ClassMethods

    # Allows you to override the string that is used in the admin interface to refer
    # to this route type. By default this is automatically calculated from the class
    # name of a decendant of Radiant::Route.
    #
    # Example:
    #
    #     class FortyTwoRoute < Radiant::Route
    #       display_name "42"
    #     end
    #
    #     FortyTwoRoute.display_name #=> "42"
    #
    def display_name(string = nil)
      if string
        @display_name = string
      else
        @display_name ||= begin
          n = name.to_s
          n.sub!(/^(.+?)(Route|Page)$/, '\1')
          n.gsub!(/([A-Z])/, ' \1')
          n.strip
        end
      end
    end
    
    # Set display name for Route class
    def display_name=(string)
      display_name(string)
    end

    # Search for a route by path
    def lookup(path)
      where(:path => normalize_path(path)).first
    end

    # Overridden here to remove the class_name column
    def attributes_protected_by_default
      super - [self.class.inheritance_column]
    end

    # The root page if one exists
    def root
      where(:parent_id => nil).first
    end

    # Remove extra slashes from the path
    def normalize_path(path)
      "/#{ path.strip }".gsub(%r{//+}, '/').gsub(%r{/^}, '')
    end

  end
  extend ClassMethods

end
