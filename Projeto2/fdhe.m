function [r,s,f] = fdhe(path)
im = imread(path);
% file1 = fopen('fst.txt','w');
% file2 = fopen('scd.txt','w');

%Se imagem em tons de cinza, nao precisa realizar operacoes
if(ndims(im) == 2)
    img = im;
    disp('nao converte');

%Se imagem RGB, transformar em hsv e calcular desvio padrao da luminancia
%(v)
%Converte pra tons de cinza apesar de no artigo dizer pra converter pra
%hsv. Exemplos mostram que isso que foi aplicado.
else
%     hsv = rgb2hsv(im);
%     img = hsv(:,:,3);
    img = rgb2gray(im);
%     disp('converte cinza');
%     disp(img);
end
% fprintf(file1, '%d\n',img);
figure, imshow(img); %figure1
stdDeviation = std2(img);
[row, col] = size(img);
% disp(stdDeviation);
figure, imhist(img); %figure2
axis([0 inf 0 9000]);
histoSize = size(imhist(img));
similar = zeros(row, col);
g = zeros(row, col);

%%%%%%%%%%%%%%%%% Calcula similaridade %%%%%%%%%%%%%%%%%
%Percorre cada pixel da matriz
for i=1:row
    for j=1:col
        similar(i, j) = membership(img, stdDeviation, i, j);
    end
end
% disp(similar);
% disp(size(similar));
%figure, imhist(similar);

%%%%%%%%%%%%%%%%% FCF (Dissimilaridade) %%%%%%%%%%%%%%%%%
fcf = 1 - similar;
% disp (fcf);
% disp(size(fcf));

%%%%%%%%%%%%%%%%% FDH %%%%%%%%%%%%%%%%%
fdh = dissimilarityHistogram(img, histoSize(1), fcf);
figure, bar(fdh,1,'hist'); %figure 3
axis([0 inf 0 1000]);
% figure, histogram(fdh);
% disp(fdh);
% disp(size(fdh));

%%%%%%%%%%%% Normaliza fdh %%%%%%%%%%%%%%%%%
total = sum(fdh);
% disp(fdh);
% disp(total);
pfd = zeros(size(fdh));
% disp(size(pfd));
for i=1:size(pfd,2)
    pfd(i) = double(fdh(i))/double(total);
end
% disp(pfd);

%%%%%%%%%%%%%%%%%% CDF %%%%%%%%%%%%%%%%%
cfd = zeros(size(pfd));
len = size(pfd,2);
cfd(1) = pfd(1);
%     disp(pfd);
% disp(len);
for i=2:len
    cfd(i) = cfd(i-1) + pfd(i);
end
f = cfd;
% disp(cfd);

%%%%%%%%%%%%%%%%% Reconstroi imagem %%%%%%%%%%%%%%%%%
%sk = s0 + (s_(l-1) - s0)cfd(rk)
%s0 = 0; s_(l-1) = 255
% disp(row);
% disp(col);
sk = 255*cfd;
s = sk;
% disp(sk);
for i=1:row
    for j=1:col
        %Indice comeca em 1 e nivel de intensidade da imagem comeca em 0
        intensidade = cfd(img(i,j)+1);
%         g(i,j) = abs(img(i,j)-(255*intensidade));
        g(i,j) = (255*intensidade);
    end
end

hi = generateHistogram(g);
figure, bar(hi,1,'hist'); %figure 4
axis([0 inf 0 9000]);
% disp(hi);

% fprintf(file2, '%d\n',g);
% disp(g);
% imwrite(g, 'saida.jpg');
figure, imshow(g);
% figure, imhist(g);
r = g;

end

function h = generateHistogram(matrix)
    array = zeros(1, 256);
    [row, col] = size(matrix);
    for i=1:row
        for j=1:col
        value = uint8(matrix(i, j) + 1);
        array(value) = array(value) + 1;
        end
    end
    h = array;
end

function fdh = dissimilarityHistogram(im, levels, fcf)
    dissimilar = zeros(1, levels);
    [row, col] = size(im);
    for i=1:row
        for j=1:col
            level = im(i,j);
            %Indice comeca em 1, valor comeca em 0
            dissimilar(level+1) = dissimilar(level+1) + fcf(i,j);
        end
    end
%     disp(dissimilar);
    fdh = dissimilar;
%     fdh = uint8(dissimilar);
end

function member = membership(array, std, x, y)
    sumi = 0;
    for i=-1:1
        sumj = 0;
        u = x+i;
        for j=-1:1            
            v = y+j;
            % Garante que nao ira passar da borda da imagem. Considera
            % elementos após as bordas como 0.
            if(u > size(array,1) || u < 1 || v > size(array,2) || v < 1)
                continue
            end
            %(|f (x, y) − f (u, v)|)
            diff = abs(array(x,y)-array(u,v));
%             disp('diff');
%             disp(diff);
            %(|f (x, y) − f (u, v)|/ σ)
            norm = double(diff)/double(std);
%             disp('norm');
%             disp(norm);
%             disp(std);
            %(1 − |f (x, y) − f (u, v)|/ σ)
            compl = 1 - norm;
%             disp('compl');
%             disp(compl)
            %max (1 − |f (x, y) − f (u, v)|/ σ, 0)
            mi = max(compl, 0);
            sumj = sumj + mi;
        end
        sumi = sumi + sumj;
    end
    member = sumi/9;
end