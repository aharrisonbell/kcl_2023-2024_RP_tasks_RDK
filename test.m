X = [-1.0 -0.8 -0.6 -0.4 -0.2 0.0 0.2 0.4 0.6 0.8 1.0 1.2 1.4 1.6 1.8 2.0];
Y = [0.1 -0.15 0.05 0.0 -0.05 10.2 10.5 11.5 8.2 9.2 10.0 10.5 10.2 10.9 10.5 11.5];
plot(X,Y)



step = @(x)x > 0;


fun = @(p,x) p(1)*step(x-p(2))
p0 = [9,-0.5];
p1 = lsqcurvefit(fun,p0,X,Y);
Z = fun(p1,linspace(min(X),max(X)));
hold on
plot(linspace(min(X),max(X)),Z,'r')