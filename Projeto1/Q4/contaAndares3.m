function contaAndares3(path)
    im = imread(path);
    figure, imshow(im);
    %Binariza com um threshold que exclui quase tudo menos o prédio
    bw = im2bw(im, 0.8);
    figure, imshow(bw);
    
    %Erosao para remover ruídos
    se = strel('square', 12);
    erode = imerode(bw, se);
    figure, imshow(erode);  
    
    %Dilata para juntar as janelas
    se = strel('line', 32, 2);
    dilate = imdilate(erode, se);
    figure, imshow(dilate);  

    cc = bwconncomp(dilate);
    disp(cc);
    disp('Numero de Andares: ');
    disp(cc.NumObjects); 
    
end