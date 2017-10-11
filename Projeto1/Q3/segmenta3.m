function segmenta3(path)
    im = imread(path);
    %Transforma de RGB para HSV e pega o valor de hue
    hsv = rgb2hsv(im);
    hue = hsv(:,:,1);
    figure, imshow(im);
%     figure, imshow(hsv);
%     figure, imshow(hue);

%     imhist(hue);
    histo = imhist(hue);
    [value, index] = max(histo);
%     disp(value);
%     disp(index);
%     disp(size(histo));
%     disp(histo);
%     figure, histo;
    [row, col] = size(hue);

    %Remove os valores ao redor do maximo
    upper = (index + 50)/256;
    lower = (index - 20)/256;
%     disp(index);
%     disp(histo(index));
%     disp(upper);
%     disp(lower);
    for i=1:row
        for j=1:col
            if(hue(i,j) >= lower && hue(i,j) <= upper)
                hsv(i,j,:) = 0;
            end
        end
    end
   
%     figure, imshow(hue);
    rgb = hsv2rgb(hsv);   
    figure, imshow(rgb);
    gray = rgb2gray(rgb);
%     figure, imshow(gray);
    level = graythresh(gray);
    bw = im2bw(gray, level);
    figure, imshow(bw);
    
    se = strel('disk', 3);
    close = imclose(bw, se);
    figure, imshow(close);

    %Encontra o maior elemento conectado
    cc = bwconncomp(close);
    numPixels = cellfun(@numel,cc.PixelIdxList);
    [biggest,idx] = max(numPixels);

    
    %Cria uma imagem do tamanho da original, toda preta e pinta de branco
    %apenas o que está no elemento.
    img = zeros(row, col);
    img(cc.PixelIdxList{idx}) = 1;
    figure, imshow(img);

    h = fspecial('laplacian');
    edges = imfilter(img, h);
    figure, imshow(edges);
    
end