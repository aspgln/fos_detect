function r = check_accuracy(testLabels, predictLabel)

   tp = 0;
    fp = 0;
    fn = 0;
    tn = 0;


    for j = 1:length(predictLabel)
        if (testLabels(j) == 1) && (predictLabel(j) == 1)
            tp = tp + 1;
        elseif (testLabels(j) == 1) && (predictLabel(j) == 0)
            fn = fn + 1;
        elseif (testLabels(j) == 0) && (predictLabel(j) == 1)
            fp = fp + 1    ;
        elseif (testLabels(j) == 0) && (predictLabel(j) == 0)
            tn = tn + 1;
        end 

    end

    precision = tp / (tp + fp);

    recall =  tp / (tp + fn);

    accuracy = (tp + tn) / (tp + tn + fp + fn );


    x = {'model 1', ''; 
        'tp', tp; 'fp', fp; 'fn', fn;
        'precision: ', precision; 'recall: ', recall; 'accuracy: ', accuracy};


    r = cell2mat(x(2:7,2));
   disp(r);
   
