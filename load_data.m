function data = load_data()

    dirname = 'data1';


    files = dir(dirname);

    s = 0;
    for idx = 1:length(files)
        if ~endsWith(files(idx).name, 'mat')
            continue;
        end

        filepath = fullfile(dirname, files(idx).name);
        filepath
        load(filepath);

        s = s + 1;
        data(s) = dat;
    end

    for s = 1:length(data)
        data(s).N = 0;
        for b = 1:length(dat.block)
            data(s).N = data(s).N + size(dat.block{b}.c, 1);
        end
    end
