function [r,s,f] = fdhe(path)
im = imread(path);
% file1 = fopen('fst.txt','w');
% file2 = fopen('scd.txt','w');

%Se imagem em tons de cinza, nao precisa realizar operacoes
if(ndims(im) == 2)
    isColor = false;
    img = im;
    disp('Imagem cinza');

%Se imagem RGB, transformar em hsv e trabalhar com a luminancia (v)
else
    isColor = true;
    imhsv = rgb2hsv(im);
    img2 = imhsv(:,:,3);
%     img = rgb2gray(im);
    img = uint8(255*img2);
    disp('Imagem colorida');
%     disp(img);
end

% fprintf(file1, '%d\n',img);
figure, imshow(img);
title('Imagem Original');

stdDeviation = std2(img);
[row, col] = size(img);
% disp(stdDeviation);

figure, imhist(img);
axis([0 inf 0 9000]);
title('Histograma Imagem Original');

histo = imhist(img);
histoSize = size(histo);
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
figure, bar(fdh,1,'hist');
axis([0 inf 0 1000]);
title('Histograma Dissimilaridade Fuzzy');
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
%         intensidade = cfd(img(i,j)+1);
% %         g(i,j) = abs(img(i,j)-(255*intensidade));
%         g(i,j) = (255*intensidade);
        g(i,j) = sk(img(i,j)+1);
    end
end

if(~isColor)
    out = uint8(g);
    figure,imshow(out);
    title('Imagem Melhorada');
    figure, imhist(out);
    axis([0 inf 0 9000]);
    title('Histograma Imagem Melhorada');

    hi = generateHistogram(g);
    % figure, bar(hi,1,'hist'); %figure 4
    % axis([0 inf 0 9000]);
    % title('Histograma Imagem Melhorada');
    % disp(hi);

    % fprintf(file2, '%d\n',g);
    % disp(g);
    % imwrite(g, 'saida.jpg');
    % figure, imshow(g);
    % title('Imagem Melhorada');
    % figure, imhist(g);
    r = out;
else

    newV = g/255;
%     disp(newV);
    imhsv(:,:,3) = newV;
    newRGB = hsv2rgb(imhsv);
    figure, imshow(newRGB);
    title('Imagem Melhorada');
    figure, imhist(newRGB);
    axis([0 inf 0 9000]);
    title('Histograma Imagem Melhorada');

%     hi = generateHistogram(g);
    % figure, bar(hi,1,'hist'); %figure 4
    % axis([0 inf 0 9000]);
    % title('Histograma Imagem Melhorada');
    % disp(hi);

    % fprintf(file2, '%d\n',g);
    % disp(g);
    % imwrite(g, 'saida.jpg');
    % figure, imshow(g);
    % title('Imagem Melhorada');
    % figure, imhist(g);
%     r = out;

end

%%%%%%%%%%%%%%%%% Calcula Entropia Discreta Normalizada %%%%%%%%%%%%%%%%%

% Normaliza histograma da imagem original
totalOriginal = sum(histo);
% disp(totalOriginal);
normalOriginal = zeros(size(histo));
for i=1:size(normalOriginal,1)
    normalOriginal(i) = double(histo(i))/double(totalOriginal);
end
% disp(normalOriginal);
original = discreteEntropy(normalOriginal);
disp(original);

% Normaliza histograma da imagem melhorada
totalMelhorada = sum(hi);
% disp(totalMelhorada);
normalMelhorada = zeros(size(hi));
for i=1:size(normalMelhorada,1)
    normalMelhorada(i) = double(hi(i))/double(totalMelhorada);
end
% disp(normalMelhorada);
melhorado = discreteEntropy(normalMelhorada);
disp(melhorado);

logMax = log(256);
diffOriginal = logMax - original;
diffMelhorado = logMax - melhorado;
razao = double(diffMelhorado)/double(diffOriginal);
den = 1/(1+razao);
disp('Entropia discreta normalizada');
disp(den);

logMax2 = log2(256);
entropiaO = entropy(img);
% disp(entropiaO);
entropiaM = entropy(out);
% disp(entropiaM);

diffO = logMax2 - entropiaO;
diffM = logMax2 - entropiaM;
razao2 = double(diffM)/double(diffO);
den2 = 1/(1+razao2);

razao3 = entropiaM/logMax2;
denominador = logMax2 - razao3 - entropiaO;
den3 = 1/(1+denominador);

disp(den2);
disp(den3);

end

function e = discreteEntropy(histog)
    soma = 0;
%     disp(size(histog));
    for i=1:256
         %Indice comeca em 1 e nivel de intensidade da imagem comeca em 0
        valor = histog(i)*log(i);
        soma = soma + valor;
    end
    e = -soma;
end

function h = generateHistogram(matrix)
    array = zeros(256, 1);
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
