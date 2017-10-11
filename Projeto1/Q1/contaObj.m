%Caminho para o objeto a ser avaliado, Caminho para o objeto de referencia
% contaObj('imagens/objetos.bmp','imagens/parafuso_porca.bmp');
function contaObj(path, ref_path)
    im = imread(path);
    ref = imread(ref_path);
    bw = im2bw(im, 0.8);
    bw_ref = im2bw(ref, 0.8);
    figure, imshow(bw);
    figure, imshow(bw_ref);
      
    inv = ~bw;
    inv_ref = ~bw_ref;
    figure, imshow(inv);
    figure, imshow(inv_ref);
    
    %Baseado na imagem de referencia, define os valores esperados de
    %parafuso e porca
    cc = bwconncomp(inv_ref);
       
    el1 = cc.PixelIdxList(1);
    el1 = size(el1{1},1);
    el2 = cc.PixelIdxList(2);
    el2 = size(el2{1},1);
    
    if(el1 < el2)
        ref_porca = el1;
        ref_parafuso = el2;
    else
        ref_porca = el2;
        ref_parafuso = el1;
    end
    
%     disp(ref_porca);
%     disp(ref_parafuso);
    
    %Compara os valores da imagem com os valores de referencia
    porcas = 0;
    parafusos = 0;
    cc = bwconncomp(inv);
    for i=1:cc.NumObjects 
        el = cc.PixelIdxList(i);
        el = size(el{1},1);
%         disp(el);
        %Compara as diferenças absolutas entre o elemento atual e a
        %referencia para parafusos e porcas. Considera o elemento como
        %pertencente ao grupo do qual ele tiver uma menor diferença.
        if (abs(el-ref_parafuso) > abs(el-ref_porca))
            porcas = porcas+1;
        else
            parafusos = parafusos+1;
        end
    end
    disp('Parafusos: ');
    disp(parafusos);
    disp('Porcas: ');
    disp(porcas);

end
