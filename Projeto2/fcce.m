function fcce(path)
im = imread(path);


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
    disp('converte cinza');
end

stdDeviation = std2(img);
[row, col] = size(img);
disp(stdDeviation);
figure, imhist(img);
axis([0 250 0 inf])
histoSize = size(imhist(img));
similar = zeros(row, col);

%Calcula similaridade
    %Percorre cada pixel da matriz
for i=1:row
    for j=1:col
        similar(i, j) = membership(img, stdDeviation, i, j);
    end
end
% disp(similar);
%figure, imhist(similar);
%FCF (Dissimilaridade)
fcf = 1 - similar;
% disp (fcf);

%FDH
fdh = dissimilarityHistogram(img, histoSize(1), fcf);
figure, plot(fdh,'bo');
axis([0 250 0 300])
% figure, histogram(fdh);
% disp(fdh);

%CACE
end

%apenas para imagem em tons de cinza
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
    fdh = dissimilar;
     
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