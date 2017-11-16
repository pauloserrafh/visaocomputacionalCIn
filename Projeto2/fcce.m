function fcce(path)
im = imread(path);
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

figure, imshow(img);
title('Imagem Original');

stdDeviation = std2(img);
media = mean2(img);
% disp(media);
% media2 = mean(img(:));
% disp(media2);
coefficientVariation = media/stdDeviation;
% disp(coefficientVariation);
[row, col] = size(img);
% disp(stdDeviation);

% figure, imhist(img); %figure2
histo = imhist(img);
figure, bar(histo,1,'hist');
axis([0 256 0 9000]);
title('Histograma Imagem Original');

histoSize = size(histo);
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
        sqr = member*member;
        c = sqr*coefficientVariation;
        contextual(i, j) = exp(-c);
%         disp(contextual(i,j));
    end
end
% disp(similar);
%figure, imhist(similar);

%%%%%%%%%%%%%%%%% FCF (Dissimilaridade) %%%%%%%%%%%%%%%%%
fcf = 1 - similar;
% fcf = 1 - contextual;
% disp(contextual);
% disp (fcf);

%%%%%%%%%%%%%%%%% FDH %%%%%%%%%%%%%%%%%
fdh = dissimilarityHistogram(img, histoSize(1), fcf);
% disp(fdh)

figure, bar(fdh,1,'hist');
axis([0 256 0 1000]);
title('Histograma Dissimilaridade Fuzzy');

% figure, plot(fdh,'bo'); %figure 3
% axis([0 250 0 300]);
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
% cfd = cumulativeDistribution(pfd);
% disp(cfd);

cfd = zeros(size(pfd));
len = size(pfd,2);
cfd(1) = pfd(1);
%     disp(pfd);
% disp(len);
for i=2:len
    cfd(i) = cfd(i-1) + pfd(i);
end
% disp(cfd);


%%%%%%%%%%%%%%%%% Reconstroi imagem fdhe %%%%%%%%%%%%%%%%%
%sk = s0 + (s_(l-1) - s0)cfd(rk)
%s0 = 0; s_(l-1) = 255
% disp(row);
% disp(col);
sk = 255*cfd;
% disp(sk);
for i=1:row
    for j=1:col
        %Indice comeca em 1 e nivel de intensidade da imagem comeca em 0
%         intensidade = cfd(img(i,j)+1);
% %         g(i,j) = abs(img(i,j)-(255*intensidade));
%         g(i,j) = (255*intensidade);
        g(i,j) = sk(img(i,j)+1);
        mi = contextual(i,j);
        compl = 1-mi;
%         I(i,j) = ((mi*g(i,j)) + (compl*img(i,j)));
        I(i,j) = ((mi*img(i,j)) + (compl*g(i,j)));
    end
end
% g2 = uint8(g);
% I = uint8(g);

% %%%%%%%%%%%%%%%%% Reconstroi imagem fcce %%%%%%%%%%%%%%%%%
% for i=1:row
%     for j=1:col
%         %Indice comeca em 1 e nivel de intensidade da imagem comeca em 0
%         mi = contextual(i,j);
%         compl = 1-mi;
%         I(i,j) = ((mi*g(i,j)) + (compl*img(i,j)));
% %         disp(mi);
% %         disp(compl);
% %         disp(g(i,j));
% %         disp(img(i,j));
% %         disp(I(i,j));
%     end
% end

if(~isColor)
    out = uint8(I);
    figure,imshow(out);
    title('Imagem Melhorada');
%     figure, imhist(out);
    histo = imhist(out);
    figure, bar(histo,1,'hist');
    axis([0 256 0 9000]);
    title('Histograma Imagem Melhorada');

%     hi = imhist(out);
    % hi = generateHistogram(g);
    % figure, bar(hi,1,'hist'); %figure 4
    % axis([0 inf 0 9000]);
    % title('Histograma Imagem Melhorada');
    % disp(hi);

    % disp(g);
    % imwrite(g, 'saida.jpg');
    % figure, imshow(g);
    % title('Imagem Melhorada');
    % figure, imhist(g);
else
    out = I/255;
%     disp(out);
%     hi = imhist(out);
    imhsv(:,:,3) = out;
    newRGB = hsv2rgb(imhsv);
    figure, imshow(newRGB);
    title('Imagem Melhorada');
%     figure, imhist(newRGB);
    histo = imhist(out);
    figure, bar(histo,1,'hist');
    axis([0 256 0 9000]);
    title('Histograma Imagem Melhorada');

%     hi = generateHistogram(g);
    % figure, bar(hi,1,'hist'); %figure 4
    % axis([0 inf 0 9000]);
    % title('Histograma Imagem Melhorada');
    % disp(hi);

    % disp(g);
    % imwrite(g, 'saida.jpg');
    % figure, imshow(g);
    % title('Imagem Melhorada');
    % figure, imhist(g);

end

%%%%%%%%%%%%%%%%% Calcula Entropia Discreta Normalizada %%%%%%%%%%%%%%%%%

disp('Entropia discreta normalizada');

logMax2 = log2(256);
entropiaO = entropy(img);
entropiaM = entropy(out);

diffO = logMax2 - entropiaO;
diffM = logMax2 - entropiaM;
razao2 = double(diffM)/double(diffO);
den2 = 1/(1+razao2);

disp(den2);

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
%     fdh = dissimilar;
    fdh = uint8(dissimilar);
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
%
% function h = generateHistogram(matrix)
%     array = zeros(1, 256);
%     [row, col] = size(matrix);
%     for i=1:row
%         for j=1:col
%         value = matrix(i, j) + 1;
%         array(value) = array(value) + 1;
%         end
%     end
%     h = array;
% end

% function cfd = cumulativeDistribution(pfd)
%     [row, col] = size(pfd);
%     cumulative = zeros(row, col);
%     cumulative(1) = pfd(1);
% %     disp(pfd);
%     for i=2:col
%         cumulative(i) = cumulative(i-1) + pfd(i);
%     end
% %     disp(cumulative);
% %     disp(cumulative);
%     cfd = cumulative;
% end

% function fdh = dissimilarityHistogram(im, levels, fcf)
%     dissimilar = zeros(1, levels);
%     [row, col] = size(im);
%     for i=1:row
%         for j=1:col
%             level = im(i,j);
%             %Indice comeca em 1, valor comeca em 0
%             dissimilar(level+1) = dissimilar(level+1) + fcf(i,j);
%         end
%     end
%     fdh = uint8(dissimilar);
% end
%
% function member = membership(array, std, x, y)
%     sumi = 0;
%     for i=-1:1
%         sumj = 0;
%         u = x+i;
%         %Garante que nao ira passar da borda da imagem
%         if(u > size(array,1))
%             u = size(array,1);
%         elseif (u < 1)
%             u = 1;
%         end
%         for j=-1:1
%             v = y+j;
%             %Garante que nao ira passar da borda da imagem
%             if(v > size(array,2))
%                 v = size(array,2);
%             elseif (v < 1)
%                 v = 1;
%             end
%             %(|f (x, y) − f (u, v)|)
%             diff = abs(array(x,y)-array(u,v));
% %             disp('diff');
% %             disp(diff);
%             %(|f (x, y) − f (u, v)|/ σ)
%             norm = double(diff)/double(std);
% %             disp('norm');
% %             disp(norm);
% %             disp(std);
%             %(1 − |f (x, y) − f (u, v)|/ σ)
%             compl = 1 - norm;
% %             disp('compl');
% %             disp(compl)
%             %max (1 − |f (x, y) − f (u, v)|/ σ, 0)
%             mi = max(compl, 0);
%             sumj = sumj + mi;
%         end
%         sumi = sumi + sumj;
%     end
%     member = sumi/9;
% end
