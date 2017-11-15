function r = fcce(path)
im = imread(path);
% file1 = fopen('fst.txt','w');
% file2 = fopen('scd.txt','w');

%Se imagem em tons de cinza, nao precisa realizar operacoes
if(ndims(im) == 2)
    img = im;
    disp('nao converte');

%Se imagem RGB, transformar em hsv e trabalhar com a luminancia (v)
else
%     isColor = true;
    imhsv = rgb2hsv(im);
    img2 = imhsv(:,:,3);
%     img = rgb2gray(im);
    img = uint8(255*img2);
    disp('Imagem colorida');
%     disp(img);
end

% fprintf(file1, '%d\n',img);
figure, imshow(img); %figure1
stdDeviation = std2(img);
media = mean2(img);
disp(media);
% media2 = mean(img(:));
% disp(media2);
coefficientVariation = media/stdDeviation;
disp(coefficientVariation);
[row, col] = size(img);
% disp(stdDeviation);
figure, imhist(img); %figure2
axis([0 250 0 inf])
histoSize = size(imhist(img));
similar = zeros(row, col);
contextual = zeros(row, col);
g = zeros(row, col);
I = zeros(row, col);

%%%%%%%%%%%%%%%%% Calcula similaridade %%%%%%%%%%%%%%%%%
%Percorre cada pixel da matriz
for i=1:row
    for j=1:col
        member = membership(img, stdDeviation, i, j);
        similar(i, j) = member;
        sqr = member.^2;
        c = sqr*coefficientVariation;
        contextual(i, j) = exp(-c);
    end
end
% disp(similar);
%figure, imhist(similar);
%FCF (Dissimilaridade)
fcf = 1 - similar;
% disp(contextual);
% disp (fcf);

%%%%%%%%%%%%%%%%% FDH %%%%%%%%%%%%%%%%%
fdh = dissimilarityHistogram(img, histoSize(1), fcf);
figure, plot(fdh,'bo'); %figure 3
axis([0 250 0 300]);
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
cfd = cumulativeDistribution(pfd);
% disp(cfd);

%%%%%%%%%%%%%%%%% Reconstroi imagem fdhe %%%%%%%%%%%%%%%%%
%sk = s0 + (s_(l-1) - s0)cfd(rk)
%s0 = 0; s_(l-1) = 255
% disp(row);
% disp(col);
for i=1:row
    for j=1:col
        %Indice comeca em 1 e nivel de intensidade da imagem comeca em 0
        g(i,j) = uint8(255*cfd(img(i,j)+1));
    end
end

%%%%%%%%%%%%%%%%% Reconstroi imagem fcce %%%%%%%%%%%%%%%%%
for i=1:row
    for j=1:col
        %Indice comeca em 1 e nivel de intensidade da imagem comeca em 0
        mi = contextual(i,j);
        compl = 1-mi;
        I(i,j) = ((mi*g(i,j)) + (compl*img(i,j)));
    end
end

hi = generateHistogram(g);
figure, plot(hi,'bo'); %figure 4
axis([0 300 0 inf]);
% disp(hi);

fprintf(file2, '%d\n',g);
% disp(g);
% disp(I);
imwrite(g, 'saida.jpg');
figure, imshow(g); %imagem fdhe
% figure, imhist(g);
figure, imshow(I); %imagem fcce
% figure, imhist(I);
r = g;

end

function h = generateHistogram(matrix)
    array = zeros(1, 256);
    [row, col] = size(matrix);
    for i=1:row
        for j=1:col
        value = matrix(i, j) + 1;
        array(value) = array(value) + 1;
        end
    end
    h = array;
end

function cfd = cumulativeDistribution(pfd)
    [row, col] = size(pfd);
    cumulative = zeros(row, col);
    cumulative(1) = pfd(1);
%     disp(pfd);
    for i=2:col
        cumulative(i) = cumulative(i-1) + pfd(i);
    end
%     disp(cumulative);
%     disp(cumulative);
    cfd = cumulative;
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
    fdh = uint8(dissimilar);
end

function member = membership(array, std, x, y)
    sumi = 0;
    for i=-1:1
        sumj = 0;
        u = x+i;
        %Garante que nao ira passar da borda da imagem
        if(u > size(array,1))
            u = size(array,1);
        elseif (u < 1)
            u = 1;
        end
        for j=-1:1            
            v = y+j;
            %Garante que nao ira passar da borda da imagem
            if(v > size(array,2))
                v = size(array,2);
            elseif (v < 1)
                v = 1;                       
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