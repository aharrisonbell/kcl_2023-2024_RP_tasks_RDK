ydata=[10 8 12 8 14 9 11 10 200 210 190 190 201 205 203 206 185 30 28 32 35 28 33 29];  
n=length(ydata);
xdata=[1:n];

ydata = trash_data
figure
plot(ydata)
hold on

sm = smooth(ydata, 20)
plot(sm)

sm = smooth(ydata, 'lowess')
plot(sm, 'r:')

dy = abs(diff(ydata));
[~,index] = sort(dy,'descend');

plot(dy)

% First segment = 1:index(1)
m = mean(ydata(1:index(1)));
plot([1,index(1)],[m,m])

% Second segment = index(1)+1:index(2)
m = mean(ydata(index(1)+1:index(2)));
plot([index(1)+1,index(2)],[m,m])

% Third segment = index(2)+1:length(ydata)
m = mean(ydata(index(2)+1:length(ydata)));
plot([index(2)+1,length(ydata)],[m,m])