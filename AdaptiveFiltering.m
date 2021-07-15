clear all;
close all;
clc;
N = 8;
f = [0 0.2 0.4 0.41 1];
m = [0 1 1 0 0];
[B, A] = yulewalk(N,f,m);
[h, w] = freqz(B,A);

figure;
plot(f,m,w/pi,abs(h),'--');
title('Filter Design');
legend('Ideal','yulewalk Designed');

fs = 8000;
ts = 1/fs;
ns = 128;
t = 0:ts:ts*(ns-1);

%generate test signal to verify filter
f1 = 750;
f2 = 2000;
f3 = 3000;
x = 1/3*sin(2*pi*f1*t) + 1/3*sin(2*pi*f2*t) + 1/3*sin(2*pi*f3*t);
tx = 1:1:length(x);
figure;
subplot(3,2,1);
plot(2*tx/ns,x);
title('Input');
grid on;

X = abs(fft(x,ns));
X = X(1:length(X)/2);
xfrq = 1:1:length(X);

subplot(3,2,2);
plot(2*xfrq/ns,X);
title('Input');
grid on;

y = filter(B,A,x);
yt = y(1:length(y)/2);
ty = 1:1:length(yt);
subplot(3,2,3);
plot(2*ty/ns,yt);
title('8th order Filter Output');
grid on;

yF = abs(fft(y,ns));
yF = yF(1:length(yF)/2);
frq = 1:1:length(yF);

subplot(3,2,4);
plot(2*frq/ns,yF);
title('8th order Filter Output');
grid on;


bits = 16;
intgr = 9;
quantizedCoeffs = sfi(B,bits, bits-intgr-1);

qy = filter(quantizedCoeffs.data,A,x);
qt = qy(1:length(qy)/2);
tq = 1:1:length(qt);
subplot(3,2,5);
plot(2*tq/ns,qt);
title('Quantized Filter Output');
grid on;

qy = abs(fft(qy,ns));
qy = qy(1:length(qy)/2);

qfrq = 1:1:length(qy);
subplot(3,2,6);
plot(2*qfrq/ns,qy);
title('Quantized Filter Output');
grid on;



%Sencond Order
z = x;
[SOS] = tf2sos(B,A);
for i=1:size(SOS)
z = filter(SOS(i,1:3),SOS(i,4:6), z);
end
z = abs(fft(z,ns));
z = z(1:length(z)/2);

figure;
frq = 1:1:length(z);
subplot(2,1,1);
plot(2*frq/ns,z);
title('Second Order Filter Output');
grid on;


bits = 16;
intgr = 9;
[qSOS,G] = tf2sos(B,A);
quantizedSOS = sfi(qSOS,bits, bits-intgr-1);
qdata = quantizedSOS.data;
zq = x;
for i=1:size(qdata)
zq = filter(qdata(i,1:3),qdata(i,4:6), zq);
end
zq = abs(fft(zq,ns));
zq = zq(1:length(zq)/2);

frq = 1:1:length(zq);
subplot(2,1,2);
plot(2*frq/ns,zq);
title('Second Order Quantized Filter Output');
grid on;
