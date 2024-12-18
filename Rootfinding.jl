module Rootfinding

using ForwardDiff

import Base.show

export Root, newton

struct Root
  root::Float64    #  approximate value of the root
  x_eps::Float64   #  estimate of the error in the x variable
  f_eps::Float64   #  function value at the root f(root)
  num_steps::Int   #  number of steps the method used
  converged::Bool  #  whether or not the stopping criterion was reached
  max_steps::Int   #  the maximum number of steps allowed
end

function Base.show(io::IO,r::Root)
  if(r.converged)
    str = string("The root is approximately x̂ = $(r.root)\n")
    str = string(str,"An estimate for the error is $(r.x_eps)\n")
    str = string(str,"with f(x̂) = $(r.f_eps)\n")
    str = string(str,"which took $(r.num_steps) steps")
  else
    str = string("The root was not found within $(r.max_steps) steps.\n");
    str = string(str,"Currently, the root is approximately x̂ = $(r.root) \n")
    str = string(str,"An estimate for the error is $(r.x_eps)\n")
    str = string(str,"with f(x̂) = $(r.f_eps)\n")
  end
  print(io,str)
end

function newton(f::Function, x0::Number; tol=1e-6, max_steps=10)
  tol > 0 || throw(ArgumentError("The parameter tol much be positive")) 
  max_steps > 0 || throw(ArgumentError("The parameter max_steps much be positive"))
  local xstep = f(x0)/ForwardDiff.derivative(f,x0) 
  local steps = 0
  while abs(xstep)>tol && steps<max_steps
    x0 = x0 - xstep
    xstep = f(x0)/ForwardDiff.derivative(f,x0)
    steps += 1
  end
  Root(x0,xstep,f(x0),steps,steps<max_steps,max_steps)
end

end # module Rootfinding