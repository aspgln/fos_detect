%sigma is the standard deviation of a gaussian distribution
sigma = 10

[x,y] = meshgrid(-50:1:50);
psi = (1 / (pi/sigma^2)) * (1 - (x.^2 + y.^2) ./ (2 * sigma^2))' .* exp(-(x.^2 + y.^2) / (2 * sigma^2))
mesh(x,y,psi)
