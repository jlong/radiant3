class Radiant::Page < Radiant::Route

  # Page Parts
  has_many :parts, :class_name => 'PagePart', :order => 'id', :dependent => :destroy
  accepts_nested_attributes_for :parts, :allow_destroy => true

  # Lookup a part by name
  def part(name)
    if new_record? or parts.to_a.any?(&:new_record?)
      parts.to_a.find {|p| p.name == name.to_s }
    else
      parts.where(:name => name.to_s).first
    end
  end

  # Does a part with name exist?
  def part?(name)
    !part(name).nil?
  end
  alias :has_part? :part?

  # Does the page inherit the part from its ancestors?
  def inherits_part?(name)
    !part?(name) && self.ancestors.any? { |page| page.part?(name) }
  end

  # Does the have a part or inherit it?
  def has_or_inherits_part?(name)
    part?(name) || inherits_part?(name)
  end

  # Redefine body to return the part by the name of 'body'.
  def body
    part('body')
  end

  # Redefine body to render all parts
  def render
    parts.map(&:content)
  end
  
  # Redefine standard #to_xml method to include parts
  def to_xml(options={}, &block)
    super(options.reverse_merge(:include => :parts), &block)
  end

  # Redefine standard #to_json method to include parts
  def to_json(options={}, &block)
    super(options.reverse_merge(:include => :parts), &block)
  end

end
