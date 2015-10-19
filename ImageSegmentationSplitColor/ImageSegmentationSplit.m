function ImageSegmentationSplit
I = imread('multifighter.jpg');
I = im2double(I);
I = rgb2gray(I);
%{
I = rgb2hsv(I);
I_h = I(:,:,1);
I_s = I(:,:,2);
I_v = I(:,:,3);
I_weighted = I_h*0.2+I_s*0.1+I_v*0.7;
I_weighted = I_weighted*256;
%}
I = I*256;
I_out = splitmerge(I, 2, @predicate);
imwrite(I_out, 'multifighter_Split.jpg');
end

%������ͨ��ʹ��һ�������Ĳ����ֽ�ķ��Ѻϲ�ԭ�����ָ�ͼ��f��
%����mindim��һ��2�����������ݵ��������涨�˱�׼�����ͼ���Ĳ����������Сά����
function  g=splitmerge(f,mindim,fun)
%������������ʵ����0���ͼ�񣬱�֤����ĺ���qtdecomp���Խ�����ֵ�1*1�Ĵ�С��
Q=2^nextpow2(max(size(f)));
[M,N]=size(f);
f=padarray(f,[Q-M,Q-N],'post');
S=qtdecomp(f,@split_test,mindim,fun);%��matlab�Դ��ĺ�����ʼ���з���ͼ��
Lmax=full(max(S(:)));%ʹ��full����������Ĵ�С����ΪS��һ��ϡ����
g=zeros(size(f));
MARKER=zeros(size(f));
%�����forѭ����ʼ���кϲ�.
for K=1:Lmax
    [vals,r,c]=qtgetblk(f,S,K);%ʹ�ú���qtgetblk�����Ĳ����ֽ��еõ�ʵ�ʵ��Ĳ���������ֵ��
    if ~isempty(vals)
        for I=1:length(r)
            xlow=r(I);
            ylow=c(I);
            xhigh=xlow+K-1;
            yhigh=ylow+K-1;
            region=f(xlow:xhigh,ylow:yhigh);
            flag=predicate2(region);
            if flag
                g(xlow:xhigh,ylow:yhigh)=1;
                MARKER(xlow,ylow)=1;
            end
        end
    end
end
g=bwlabel(imreconstruct(MARKER,g));%ʹ�ú���bwlabel���ÿһ���������򣬲��ò�ͬ������ֵ��ע��
g=g(1:M,1:N);
end

%��������splitmerge������һ���֣��������Ƿ�quardregion���ֽ⣬����ֵ����v.
%�߼�ֵΪ���Ӧ�ñ��ֽ⣬���򲻱��ֽ⡣
%��ÿһ���Ͻ��зֽ���ԣ����ν�ʺ���predicate����TRUE��������ͱ��ֽ⣬v���ʵ���Ԫ��ֵ�ͱ���Ϊtrue��������Ϊfalse��
function v=split_test(B,mindim,fun)
K=size(B,3);
v(1:K)=false;
for I=1:K
    quadregion=B(:,:,I);
    if size(quadregion,1)<=mindim
        v(I)=false;
        continue
    end
    flag=feval(fun,quadregion);
    if flag
        v(I)=true;
    end
end
end

%��������������flag��ֵ
function flag=predicate(region)
sd=std2(region);%�����׼ƫ��
flag=(sd>2);%sd��׼ƫ��
end

function flag2=predicate2(region)
m=mean2(region);%����ƽ��ֵ
flag2=(m<150);%mƽ��ֵ��Χ��
end

function I_bw = ThresholdSplit(I)
level = graythresh(I);
disp(level);
I_bw = im2bw(I, level);
end
