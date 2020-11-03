function [results, particles] = forward(N, num_particles, init_fn, choice_fn, update_fn)

    choices = [];
    for i=1:num_particles
        particles(i) = init_fn();
        [w(i) c(i,:)] = choice_fn(1, particles(i));
    end
    liks(1) = mean(w);
    choices = [choices; mean(c,1)];

    particles = resample_particles(particles, w);

    for n=2:N
        for i=1:num_particles
            particles(i) = update_fn(n-1, particles(i));
            [w(i) c(i,:)] = choice_fn(n, particles(i));
        end
        liks(n) = mean(w);
        choices = [choices; mean(c,1)];
    
        particles = resample_particles(particles, w);
    end
    
    for i=1:num_particles
        particles(i) = update_fn(n, particles(i)); % last update of posterior
    end

    results.choices = choices;
    results.liks = liks;

    save forward.mat
