class Radiant::RoutesController < Radiant::BaseController

  # Lookup the route for the current path and show it.
  def show
    path = params[:path]
    path = path === Array ? path.join('/') : path.to_s
    route = Radiant::Route.lookup(path)
    unless route.nil?
      route.process(request, response)
      self.response_body = response.body
    else
      not_found(path)
    end
  end

  private

    # Render the 404 not found page.
    def not_found(path)
      raise ActionController::RoutingError.new("Route not found for #{path}")
    end

end
