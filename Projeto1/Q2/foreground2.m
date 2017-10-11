function foreground2(path)
    im = imread(path);
    figure, imshow(im);
    
    gray = rgb2gray(im);
    figure, imshow(gray);
    
    gauss = fspecial('gaussian', 5, 15);
    blur = imfilter(gray, gauss);
    figure, imshow(blur);
  
    edges = edge(blur,'log');
    figure, imshow(edges);
    
    %Fechamento. 
    se = strel('rectangle', [5, 20]);
    close = imclose(edges, se);
    cc = bwconncomp(close);
    figure, imshow(close);
    
    %Retorna o maior elemento conectado encontrado
    numPixels = cellfun(@numel,cc.PixelIdxList);
    [biggest,idx] = max(numPixels);
    

    %Cria uma imagem do tamanho da original, toda preta e pinta de branco
    %apenas o que está no elemento.
    [row, col, x] = size(im);
    img = zeros(row, col);
    img(cc.PixelIdxList{idx}) = 1;
    figure, imshow(img);
    
    %Remove as bordas que ficaram brancas  
    for i=1:row
        for j=1:30
            img(i,j) = 0;
        end
    end
    
    for i=1:col
        for j=1:8
            img(j, i) = 0;
        end
        for j=row:-1:(row-20)
            img(j,i) = 0;
        end
    end
    figure, imshow(img);
    
    %Preenche os buracos
    fill = imfill(img, 'holes');
    figure, imshow(fill);
    
    %Opera na imagem original deixando apenas o selecionado
    for i=1:row
        for j=1:col
            if(fill(i,j) == 0)
                im(i,j,:) = 0;
            end
        end
    end
    
    figure, imshow(im); 
    
end