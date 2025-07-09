clc;
clear;

% Step 1: Generate random bits
N = 10000;
data_bits = randi([0 1], N, 1);

% Step 2: QPSK Modulation
data_reshaped = reshape(data_bits, [], 2);
symbols = zeros(size(data_reshaped,1), 1);

for i = 1:size(data_reshaped,1)
    b = data_reshaped(i,:);
    if isequal(b, [0 0])
        symbols(i) = (1 + 1i) / sqrt(2);
    elseif isequal(b, [0 1])
        symbols(i) = (-1 + 1i) / sqrt(2);
    elseif isequal(b, [1 1])
        symbols(i) = (-1 - 1i) / sqrt(2);
    elseif isequal(b, [1 0])
        symbols(i) = (1 - 1i) / sqrt(2);
    end
end

% Step 3-5: SNR loop and BER
snr_dB = 0:1:10;
ber = zeros(size(snr_dB));

for k = 1:length(snr_dB)
    snr_linear = 10^(snr_dB(k)/10);
    noise_power = 1 / snr_linear;
    noise = sqrt(noise_power/2) * (randn(size(symbols)) + 1i*randn(size(symbols)));
    
    rx = symbols + noise;
    
    rx_bits = zeros(size(data_bits));
    
    for i = 1:length(rx)
        real_part = real(rx(i));
        imag_part = imag(rx(i));
        
        if real_part > 0
            rx_bits(2*i - 1) = 0;
        else
            rx_bits(2*i - 1) = 1;
        end
        
        if imag_part > 0
            rx_bits(2*i) = 0;
        else
            rx_bits(2*i) = 1;
        end
    end
    
    errors = sum(rx_bits ~= data_bits);
    ber(k) = errors / N;
end

% Plot BER vs SNR
semilogy(snr_dB, ber, '-o');
xlabel('SNR (dB)');
ylabel('Bit Error Rate (BER)');
title('QPSK BER vs SNR');
grid on;

% Plot Constellation for a sample SNR
snr_sample = 5;
snr_linear = 10^(snr_sample/10);
noise_power = 1 / snr_linear;
noise = sqrt(noise_power/2) * (randn(size(symbols)) + 1i*randn(size(symbols)));
rx_sample = symbols + noise;

figure;
plot(real(rx_sample), imag(rx_sample), '.');
title(['QPSK Constellation at SNR = ', num2str(snr_sample), ' dB']);
xlabel('In-phase');
ylabel('Quadrature');
grid on;
axis equal;
