close all;
clear all;
nu = 5; %5 TYPES OF CRYPTOS

%MODELS OF THE CRYPTOS
A1=[-0.068003  0 0.29961 0.65284];%BTC
A2=[-0.044311  0 0.11302 0.87731]; %DASH
A3=[ 0.061978  0 0.18807 0.69391]; %ETH
A4=[0.094792  0 0.20566 0.63792]; %NEO
A5=[0.0005393  0 0.034787  0.93624]; %ZEC

%INITIAL HISTORIC:
x1=[246844;246369;247398;247663]; %BTC
x2=[243452;243466;244946;244515]; %DASH
x3=[263368;263602;264999;265867]; %ETH
x4=[263421;263691;265285;243336]; %NEO
x5=[259230;260344;260440;260463]; %ZEC
x1_110=[];
x2_110=[];
x3_110=[];
x4_110=[];
x5_110=[];
x1_90=[];
x2_90=[];
x3_90=[];
x4_90=[];
x5_90=[];

price=0;
constraints=[];
hp_7=[1];
for i=1:51
    i= 7*i+1;
    hp_7=[hp_7, i];
end

z = sdpvar(repmat(nu,1,1),repmat(1,1,1));
value_of_return = sdpvar(repmat(1,1,size(hp_7,2)),repmat(1,1,size(hp_7,2)));
initial_inversion = 5000; %Initial inversion

u_7=zeros(nu,size(hp_7,1));
benefit_7=zeros(1,size(hp_7,1));
benefit_7_total=0;

for p=hp_7
    constraints=[];
    price=0;
    for i=p:p+6
        %Apply the model of the evolution of the crypto
        if i==1
            disp('es este el primer paso')
          p1(i+1)=A1*x1+30102;
    
          p2(i+1)=A2*x2+13753;
    
          p3(i+1)=A3*x3+14263;
    
          p4(i+1)=A4*x4+15672;
    
          p5(i+1)=A5*x5+7154.4;
          
        else
          p1(i+1)=A1*x1(i:i+3)+30102;
         
          p2(i+1)=A2*x2(i:i+3)+13753;
          
          p3(i+1)=A3*x3(i:i+3)+14263;
    
          p4(i+1)=A4*x4(i:i+3)+15672;
    
          p5(i+1)=A5*x5(i:i+3)+7154.4;
          
        end 
        
        p1_110(i+1)= p1(i+1)*1.05;
        p1_90(i+1)= p1(i+1)*0.95;
        p2_110(i+1)= p2(i+1)*1.05;
        p2_90(i+1)= p2(i+1)*0.95;
        p3_110(i+1)= p3(i+1)*1.05;
        p3_90(i+1)= p3(i+1)*0.95;
        p4_110(i+1)= p4(i+1)*1.05;
        p4_90(i+1)= p4(i+1)*0.95;
        p5_110(i+1)= p5(i+1)*1.05;
        p5_90(i+1)= p5(i+1)*0.95;
        
      x1_110=[x1_110; p1_110(i+1)];
      x2_110=[x2_110; p2_110(i+1)];
      x3_110=[x3_110; p3_110(i+1)];
      x4_110=[x4_110; p4_110(i+1)];
      x5_110=[x5_110; p5_110(i+1)];
      
      x1_90=[x1_90;  p1_90(i+1)];
      x2_90=[x2_90;  p2_90(i+1)];
      x3_90=[x3_90;  p3_90(i+1)];
      x4_90=[x4_90;  p4_90(i+1)];
      x5_90=[x5_90;  p5_90(i+1)];
           
%       Generate random value between two extrems:
%       r = a + (b-a).*rand(N,1)
      
      p1r= p1_90(i+1)+ (p1_110(i+1)-p1_90(i+1)).*rand(1,1);
      p2r= p2_90(i+1)+ (p2_110(i+1)-p2_90(i+1)).*rand(1,1);
      p3r= p3_90(i+1)+ (p3_110(i+1)-p3_90(i+1)).*rand(1,1);
      p4r= p4_90(i+1)+ (p4_110(i+1)-p4_90(i+1)).*rand(1,1);
      p5r= p5_90(i+1)+ (p5_110(i+1)-p5_90(i+1)).*rand(1,1);
      
      x1=[x1;  p1r];
      x2=[x2;  p2r];
      x3=[x3;  p3r];
      x4=[x4;  p4r];
      x5=[x5;  p5r];
      
       A= [x1, x2, x3, x4, x5];
       %Model of the evolution of the benefit with the controller
        if i>=2
        S=cov(A);
       end
      
       if i>=2
        n_crypt= initial_inversion./A(2-1,:); %The cryptos that you can buy with the initial inversion       
        value_of_return{i}= n_crypt.*A(i,:)*z; %profit along the horizon with the first bought cryptos and a controller that has to choose only one time the proportion in every crypto
        price= price+ value_of_return{i}; %We want to maximize our benefit in the all horizon
        constraints=[constraints, sum(z)<=1, zeros(nu,1)<=z<=[1;1;1;1;1],value_of_return{i}>=5000];
       end 
       
    end
    value=value_of_return{i}-5000;
    constraints=[constraints];
    optimize(constraints, -value+z'*S*z);
    
    for i=p:p+6
        if sum(double(z))==0
                benefit_7(:,i)=value_of_return{i};
            else
                benefit_7(:,i)=value_of_return{i}-5000;
        end
    end
    u_7(:,p:p+6)=double(z).*ones(5,7);
    benefit_7_total=benefit_7_total+value;
    
end

hp_15=[1];

for i=1:23
    i= 15*i+1;
    hp_15=[hp_15, i];
end
z = sdpvar(repmat(nu,1,1),repmat(1,1,1));
value_of_return = sdpvar(repmat(1,1,size(hp_15,2)),repmat(1,1,size(hp_15,2)));
initial_inversion = 5000; %Initial inversion
u_15=zeros(nu,size(hp_15,1));
benefit_15=zeros(1,size(hp_15,1));
benefit_15_total=0;
for p=hp_15
    constraints=[];
    price=0;
    for i=p:p+14
       %Model of the evolution of the benefit with the controller
       if i>=2
       S=cov(A);
       end
     
       if i>=2
        n_crypt= initial_inversion./A(2-1,:); %The cryptos that you can buy with the initial inversion       
        value_of_return{i}= n_crypt.*A(i,:)*z; %profit along the horizon with the first bought cryptos and a controller that has to choose only one time the proportion in every crypto
        price= price+ value_of_return{i}; %We want to maximize our benefit in the all horizon
        constraints=[constraints, sum(z)<=1, zeros(nu,1)<=z<=[1;1;1;1;1],value_of_return{i}>=5000];
       end 
       
    end
    value=value_of_return{i}-5000;
    constraints=[constraints];
    optimize(constraints, -value+z'*S*z);
    u_15(:,p:p+14)=double(z).*ones(5,15);
    
    for i=p:p+14
    if sum(double(z))==0
            benefit_15(:,i)=value_of_return{i};
        else
            benefit_15(:,i)=value_of_return{i}-5000;
    end
    end
    benefit_15_total=benefit_15_total+value-initial_inversion;
end

hp_30=[1];
for i=1:11
    i= 30*i+1;
    hp_30=[hp_30, i];
end
z = sdpvar(repmat(nu,1,1),repmat(1,1,1));
value_of_return = sdpvar(repmat(1,1,size(hp_30,2)),repmat(1,1,size(hp_30,2)));
initial_inversion = 5000; %Initial inversion
u_30=zeros(nu,size(hp_30,1));
benefit_30=zeros(1,size(hp_30,1));
benefit_30_total=0;
for p=hp_30
    hp_30=[1];
    constraints=[];
    price=0;
    for i=p:p+29
       %Model of the evolution of the benefit with the controller
       if i>=2
       S=cov(A);
       end
     
       if i>=2
        n_crypt= initial_inversion./A(2-1,:); %The cryptos that you can buy with the initial inversion       
        value_of_return{i}= n_crypt.*A(i,:)*z; %profit along the horizon with the first bought cryptos and a controller that has to choose only one time the proportion in every crypto
        price= price+ value_of_return{i}; %We want to maximize our benefit in the all horizon
        constraints=[constraints, sum(z)<=1, zeros(nu,1)<=z<=[1;1;1;1;1], value_of_return{i}>=5000];
       end 
    end
    price=price-initial_inversion;
    constraints=[constraints];
    value= value_of_return{i} - initial_inversion;
    optimize(constraints, -value+z'*S*z);
    u_30(:,p:p+29)=double(z).*ones(5,30);
    
    for i=p:p+29
    if sum(double(z))==0
            benefit_30(:,i)=value_of_return{i};
        else
            benefit_30(:,i)=value_of_return{i}-5000;
        end
    end
    benefit_30_total=benefit_30_total+value-initial_inversion;
end

% figure()
% plot(x1(1:end-1,:));
% hold on
% plot(x1_110(1:end-1,:), '--');
% hold on
% plot(x1_90(1:end-1,:), '--');
% legend('BTC', '105% of BTC', '95% of BTC');
% xlabel('time (day)')
% ylabel('Value of the crypto')
% 
% 
% figure()
% plot(x2(1:end-1,:));
% hold on
% plot(x2_110(1:end-1,:), '--');
% hold on
% plot(x2_90(1:end-1,:), '--');
% legend('DASH', '105% of DASH', '95% of DASH');
% xlabel('time (day)')
% ylabel('Value of the crypto')
% 
% figure()
% plot(x3(1:end-1,:));
% hold on
% plot(x3_110(1:end-1,:), '--');
% hold on
% plot(x3_90(1:end-1,:), '--');
% legend('ETH', '105% of ETH', '95% of ETH');
% xlabel('time (day)')
% ylabel('Value of the crypto')
% 
% 
% figure()
% plot(x4(1:end-1,:));
% hold on
% plot(x4_110(1:end-1,:), '--');
% hold on
% plot(x4_90(1:end-1,:), '--');
% legend('NEO', '105% of NEO', '95% of NEO');
% xlabel('time (day)')
% ylabel('Value of the crypto')
% 
% 
% 
% figure()
% plot(x5(1:end-1,:));
% hold on
% plot(x5_110(1:end-1,:), '--');
% hold on
% plot(x5_90(1:end-1,:), '--');
% legend('ZEC', '105% of ZEC', '95% of ZEC');
% xlabel('time (day)')
% ylabel('Value of the crypto')

% 
% figure()
% plot(x1(1:end-1,:));
% hold on
% plot(x2(1:end-1,:));
% hold on
% plot(x3(1:end-1,:));
% hold on
% plot(x4(1:end-1,:));
% hold on
% plot(x5(1:end-1,:)); 
% legend('BTC_d', 'DASH_d', 'ETH_d', 'NEO_d', 'ZEC_d');
% xlabel('time (day)')
% ylabel('Value of the crypto')

figure()
plot(u_30(1,:),'r')
hold on
plot(u_30(2,:),'b')
hold on
plot(u_30(3,:),'g')
hold on
plot(u_30(4,:),'y')
hold on
plot(u_30(5,:),'m')
legend('BTC', 'DASH', 'ETH', 'NEO', 'ZEC');
xlabel('time (day)')
ylabel('% inversion')



figure()
plot(u_7(1,:),'r')
hold on
plot(u_7(2,:),'b')
hold on
plot(u_7(3,:),'g')
hold on
plot(u_7(4,:),'y')
hold on
plot(u_7(5,:),'m')
legend('BTC', 'DASH', 'ETH', 'NEO', 'ZEC');
xlabel('time (day)')
ylabel('% inversion')


figure()
plot(benefit_7(1,1:360),'r')
hold on
plot(benefit_15(1,1:360),'b')
hold on
plot(benefit_30(1,1:360),'m')
legend('Benefits when hp=7', 'Benefits when hp=15', 'Benefits when hp=30');
xlabel('time (day)')
ylabel('Value of benefit')

figure()
plot(benefit_7(1,1:360),'r');legend('Benefits when hp=7');
xlabel('time (day)')
ylabel('Value of benefit')


% 
% figure()
% plot(DATA_MODEL(:,1));
% hold on
% plot(DATA_MODEL(:,2));
% hold on
% plot(DATA_MODEL(:,3));
% hold on
% plot(DATA_MODEL(:,4));
% hold on
% plot(DATA_MODEL(:,5)); 
% legend('BTC', 'DASH', 'ETH', 'NEO', 'ZEC');
% xlabel('time (day)')
% ylabel('Value of the crypto')

%Linear model
% mdl_BTC = fitlm([BTC(:,3:5)],BTC(:,1))
% mdl_DASH = fitlm([DASH(:,3:5)],DASH(:,1))
% mdl_ETH = fitlm([ETH(:,3:5)],ETH(:,1))
% mdl_NEO = fitlm([NEO(:,3:5)],NEO(:,1))
% mdl_ZEC = fitlm([ZEC(:,3:5)],ZEC(:,1))
% 
% figure();
% plot(p1(2:end))
% hold on;
% plot(p2(2:end))
% hold on;
% plot(p3(2:end))
% hold on;
% plot(p4(2:end))
% hold on;
% plot(p5(2:end))
% legend('BTC', 'DASH', 'ETH', 'NEO', 'ZEC');
% xlabel('time (day)')
% ylabel('Value of the crypto')