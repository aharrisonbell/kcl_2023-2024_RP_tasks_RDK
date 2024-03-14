function output = heaviside(xdata, ydata);
% https://stackoverflow.com/questions/48794136/fitting-data-with-heaviside-step-function


dy = abs(diff(ydata));
[~,index] = sort(dy,'descend');

% First segment = 1:index(1)
m = mean(ydata(1:index(1)));
plot([1,index(1)],[m,m])

% Second segment = index(1)+1:index(2)
m = mean(ydata(index(1)+1:index(2)));
plot([index(1)+1,index(2)],[m,m])

% Third segment = index(2)+1:length(ydata)
m = mean(ydata(index(2)+1:length(ydata)));
plot([index(2)+1,length(ydata)],[m,m])
return