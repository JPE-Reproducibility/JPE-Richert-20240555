function verify_env()
% Self-contained environment check + numerical fingerprint (one file; no helpers).
%   - Prints the environment and the fingerprint. To GENERATE the reference, run it
%     once on the canonical machine and copy the printed "fingerprint" value below.
%   - Then HALTS with a noisy error unless the environment matches. Call it from the
%     top of main_cds.m (right after the addpath block).
%
% Paste from a correctly-configured canonical run (MKL_CBWR=AVX512, AVX-512 CPU):
REF_FINGERPRINT = '4744784532492610674';   % <-- the printed fingerprint, AS A STRING (keep quotes!)
REQ_RELEASE     = '2023a';                  % <-- the MATLAB release printed below

% ---- compute fingerprint (single-threaded, side-effect-free) ----
fp_str = sprintf('%u', local_fingerprint());

% ---- print environment (also recorded in the run's diary) ----
if ispc, [~,cpu] = system('wmic cpu get name');
else,    [~,cpu] = system('grep -m1 "model name" /proc/cpuinfo'); end
fprintf('--- verify_env ---\n');
fprintf('  MATLAB %s | release %s\n', version, version('-release'));
try, fprintf('  BLAS %s\n', version('-blas')); catch, end
fprintf('  CPU %s\n', strtrim(cpu));
fprintf('  MKL_CBWR "%s" | maxNumCompThreads %d\n', getenv('MKL_CBWR'), maxNumCompThreads);
fprintf('  fingerprint %s\n', fp_str);

% ---- checks (noisy errors) ----
cbwr = getenv('MKL_CBWR');
if ~strcmpi(cbwr, 'AVX512')
    error('verify_env:MKL_CBWR', ...
        ['MKL_CBWR is "%s" but must be "AVX512". Set it in the OS BEFORE launching MATLAB ' ...
         '(Windows: setx MKL_CBWR AVX512, new terminal/restart; Linux: export MKL_CBWR=AVX512), ' ...
         'then relaunch. See README.'], cbwr);
end
if ~strcmp(version('-release'), REQ_RELEASE)
    error('verify_env:MATLABversion', ...
        'MATLAB release is %s but %s is required (see README).', version('-release'), REQ_RELEASE);
end
if isunix
    [~, f] = system('grep -m1 -o avx512f /proc/cpuinfo');
    if ~contains(f, 'avx512f')
        error('verify_env:AVX512', 'This CPU lacks AVX-512. Run on AVX-512 hardware (see README).');
    end
end
if ~strcmp(fp_str, REF_FINGERPRINT)
    error('verify_env:fingerprint', ...
        ['Numerical fingerprint %s does NOT match the reference %s.\n' ...
         'This environment will not reproduce the published tables.\n' ...
         'Confirm MATLAB %s, MKL_CBWR=AVX512, and AVX-512 hardware (see README).'], ...
         fp_str, REF_FINGERPRINT, REQ_RELEASE);
end
fprintf('  OK\n');
end

% ===== local fingerprint: single-threaded; restores threads AND RNG state =====
function h = local_fingerprint()
nt  = maxNumCompThreads(1);
cu1 = onCleanup(@() maxNumCompThreads(nt));
s   = rng;
cu2 = onCleanup(@() rng(s));
rng(12345,'twister');
A = rand(256); B = rand(256);
v    = zeros(1,4);
v(1) = sum(sum(A*B));                                     % BLAS gemm
v(2) = sum(exp(-rand(1e5,1)));                            % VML exp
v(3) = sum(betainv(rand(1e4,1)*0.998+0.001, 2.3, 4.1));  % stat fns
s2   = sort(rand(1e5,1));  v(4) = sum(cumsum(s2));        % sort / cumsum
h    = typecast(sum(v), 'uint64');
end
