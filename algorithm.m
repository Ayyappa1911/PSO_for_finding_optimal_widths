
n = 11; % no of transistors

particles = zeros(n,1); 
velocities = zeros(n,1);

Pbest = zeros(n,1);
Gbest = zeros(n,1);

r = zeros(n,1);

for i = 1 : n 
    Pbest(i) = randi([150, 250]);
    velocities(i) = 0;
end

particles(1) = 360; % Initial transistor widths !!
particles(2) = 360;
particles(3) = 360;
particles(4) = 360;
particles(5) = 360;
particles(6) = 180;
particles(7) = 360;
particles(8) = 180;
particles(9) = 180;
particles(10) = 180;
particles(11) = 180;


Wmax = 0.9;
Wmin = 0.2;

w = 0.9;
c1 = 1.8;
c2 = 1.8;

Max_gen = 2000;

Gbest = Pbest;

generation = 0;

while(generation < Max_gen)

%     delay11 = fitness_down(width_str( particles ));
%     delay12 = fitness_up(width_str( particles ));
%     delay21 = fitness_down(width_str( Pbest )) ;
%     delay22 = fitness_up(width_str( Pbest ));
%     if(delay11 + delay12 < delay21+ delay22)
    if(fitness(width_str(particles)) < fitness(width_str(Pbest)))
    %if(fitness_down(width_str( particles )) < fitness_down(width_str( Pbest )) && fitness_up(width_str( particles )) < fitness_up(width_str( Pbest )))
        Pbest = particles;
    end
    
%     Pbest_delay = fitness_down(width_str( Pbest )) + fitness_up(width_str( best ));
%     Gbest_delay = fitness_down(width_str( Gbest )) + fitness_up(width_str( Gbest ));

%     if(Pbest_delay < Gbest_delay)
    %if(fitness_down(width_str( Pbest )) < fitness_down(width_str( Gbest )) && fitness_up(width_str( Pbest )) < fitness_up(width_str( Gbest )))
    if(fitness(width_str(particles))  < fitness(width_str(Gbest)) )
        Gbest = Pbest;
    end
    
    w = Wmax - generation*(Wmax-Wmin)/Max_gen;
    for j = 1 : n

        k1 = (randn(1));

        k2 = (randn(1));

        velocities(j) = w * velocities(j) + (Pbest(j) - particles(j)) * c1 * k1 + (Gbest(j) - particles(j)) * c2 * k2;
        particles(j) = particles(j) + velocities(j);

        if(particles(j) > 800) % Maximum width shouldn't exceed 400
            particles(j) = randi([600,700]);
            velocities(j) = 0.0001;

        end

        if(particles(j) < 10) % Minimum shouldn't go down less than 90.
           particles(j) = randi([20,100]);
           velocities(j) = 0.0001;
        end
    end


    generation = generation + 1;
    disp(generation)
%     disp('Pbest = ')
%     disp(Pbest_delay)
%     disp('Gbest = ')
%     disp(Gbest_delay)
    
    finish = 0;
    for i = 1 : n
        finish = finish + velocities(i);
    end
    if(finish == 0)
        generation = Max_gen + 5;
    end

end

function widths_string = width_str(widths) 
    widths_string = ["","","","","","","","","","",""]; %Should keep the no of empty as n(no of variables)
    for i = 1 : length(widths)
        widths_string(i) = "w=" + widths(i) + "nm";
    end
end



% Do the similar changes to fitness_up as similar to fitness_down function.
function delay = fitness(widths)


netlist = 'C:\Users\ayyap\OneDrive\Documents\work\DCMOS\project\proposed_level_shifter.net'; % change this to practice.net path


fid = fopen(netlist,'w+');
fprintf(fid,'* D:\\IIITB_coursework\\DCMOS_Project\\sources\\proposed_LS.asc\r\n');
fprintf(fid, char('M1 N007 N006 0 0 NMOS l=65n '+widths(1)'+'\r\n'));
fprintf(fid,char('M2 N002 Vin N007 0 NMOS l=65n '+widths(2)+'\r\n'));
fprintf(fid,char('M3 N002 N002 N001 N001 PMOS l=65n '+widths(3)+'\r\n'));
fprintf(fid,char('M4 N005 N002 N001 N001 PMOS l=65n '+widths(4)+'\r\n'));
fprintf(fid,char('M5 N005 N004 Vin 0 NMOS l=65n '+widths(5)+'\r\n'));
fprintf(fid,char('M6 N003 N003 N001 N001 PMOS l=65n '+widths(6)+'\r\n'));
fprintf(fid,char('M7 N006 N005 N003 N001 PMOS l=65n '+widths(7)+'\r\n'));
fprintf(fid,char('M8 N006 N005 0 0 NMOS l=65n '+widths(8)+'\r\n'));
fprintf(fid,char('M9 N006 Vout N001 N001 PMOS l=65n '+widths(9)+'\r\n'));
fprintf(fid,char('M10 Vout N006 N001 N001 PMOS l=65n '+widths(10)+'\r\n'));
fprintf(fid,char('M11 Vout N006 0 0 NMOS l=65n '+widths(11)+'\r\n'));
fprintf(fid,'V1 N001 0 1.2\r\n');
fprintf(fid,'V2 N004 0 0.3\r\n');
fprintf(fid,'V3 Vin 0 PWL(0 0 9.99n 0 10.00n 0.3 20n 0.3 30n 0.3 34.99n 0.3 35n 0 40n 0)\r\n');
fprintf(fid,'.model NMOS NMOS\r\n');
fprintf(fid,'.model PMOS PMOS\r\n');
fprintf(fid,'.lib C:\\Users\\ayyap\\OneDrive\\Documents\\LTspiceXVII\\lib\\cmp\\standard.mos\r\n');
fprintf(fid,'.include 65nm_mf.txt\r\n');
fprintf(fid,'.tran 200n\r\n');
fprintf(fid,'.meas t1 find time when V(Vin)=0.15\r\n');
fprintf(fid,'.meas t2 find time when V(Vout)=0.6\r\n');
fprintf(fid,'.meas tpdr param t2-t1\r\n');
fprintf(fid,'.meas t3 find time when V(Vin)=0.15 TD=30n\r\n');
fprintf(fid,'.meas t4 find time when V(Vout)=0.6 TD=30n\r\n');
fprintf(fid,'.meas tpdf param t4-t3\r\n');
fprintf(fid,'.meas power1 AVG -I(V1)*V(n001)\r\n');
fprintf(fid,'.meas power2 AVG -I(V2)*V(n004)\r\n');
fprintf(fid,'.meas PDP param (tpdf+tpdr)/2*(Power1+power2)\r\n');
fprintf(fid,'.backanno\r\n');
fprintf(fid,'.end\r\n');
fid = fclose(fid);

dos('LTSpice_call.bat')
pause(5)

logfile = 'C:\Users\ayyap\OneDrive\Documents\work\DCMOS\project\proposed_level_shifter.log';

fid1 = fopen(logfile,'r');
tline = fgetl(fid1);
delay = 1;
while ischar(tline)
    if(contains(tline,"pdp: (tpdf+tpdr)/2*(power1+power2)="))
        line_parts = split(tline,"=");
        de_str = line_parts(2);
        delay = str2double(de_str);
        delay = abs(delay);
    end
    tline = fgetl(fid1);
end
fclose(fid1);

dos('LTSpice_end.bat')


disp('delay1')
disp(delay)

end






