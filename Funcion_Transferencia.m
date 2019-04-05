clc
%Y(s)
disp('----------------------------------------------------------------');
disp('--------------------FUNCION DE TRANSFERENCIA--------------------');
disp('----------------------------------------------------------------');
 
%U(s)
orden_ent=input('Indique el orden de la ecuacion de entrada U(S): ');
ou=sprintf('');
eus=sprintf('');
gus=sprintf('');
for i=1:orden_ent+1
    ou=sprintf('');
    j=double(orden_ent+1-i);
    for ramp=1:j
       ou=[ou,'´'];
    end
    coef_us=['Indique el coeficiente de U',ou,': '];
    val_us(i)=input(coef_us);
    if val_us(i)<0
        eus=[eus,num2str(val_us(i)),'U',ou];        
    else
        if val_us(i)>0
            if i==1
                eus=[eus,num2str(val_us(i)),'U',ou];
            else
                eus=[eus,'+',num2str(val_us(i)),'U',ou];
            end
        end
    end
end

orden_sal=input('Indique el orden de la ecuacion de salida (Y(S)): ');
eys=sprintf('');
gys=sprintf('');
for i=1:orden_sal+1
    oy=sprintf('');
    j=double(orden_sal+1-i);
    for ramp=1:j
       oy=[oy,'´'];
    end
    coef_ys=['Indique el coeficiente de Y',oy,': '];
    val_ys(i)=input(coef_ys);
    if val_ys(i)<0
        eys=[eys,num2str(val_ys(i)),'Y',oy];
    else
        if val_ys(i)>0
            if i==1
                eys=[eys,num2str(val_ys(i)),'Y',oy];
            else
                eys=[eys,'+',num2str(val_ys(i)),'Y',oy];
            end
        end
    end
end

%Ceros, polos Y ganancia
[z,p,k]=tf2zp(val_us,val_ys);

fx=fprintf('');
fprintf('\n');
disp('Ecuacion diferencial:')
fx=[eys,' = ',eus];
disp(fx);
 
g=fprintf('');
fprintf('\n');
disp('Funcion de Transferencia')
disp('G(s)=')
g=tf(val_us,val_ys)

disp('Los ceros de este sistema son:')
if(isempty(z))
    disp(' No hay ceros')
    fprintf('\n');
else
    disp(z);
end
disp('Los polos de este sistema son:')
disp(p);
disp('La ganancia de este sistema es:')
disp(k);

%Estabilidad
disp('Estabilidad:')
for i=1 : length(p)
    if(p(i)>0)
        fprintf('Este sistema es inestable.');
        fprintf('\n');
        break;
    end
    if(i==length(p))
         fprintf('Este sistema es estable');
         fprintf('\n');
         break;
    end
end
fprintf('\n')
%Amortiguamiento
[wn,zeta]=damp(g);
cWn=wn(1);
cZeta=zeta(1);
if(cZeta==1)
    disp('El sistema tiene amortiguamiento critico')
elseif(cZeta==0)
    disp('El sistema es no amortiguado')
elseif(cZeta>1)
    disp('El sistema es sobreamortiguado')
elseif((cZeta>0) && (cZeta<1))
    disp('El sistema esta bajo amortiguamiento')
elseif(cZeta<0)
    disp('El sistema tiene amortiguamiento negativo')
end
step(val_us,val_ys)

fprintf('\n');


%Sobrepaso
disp('Sobrepaso porcentual:')
sp=exp((-cZeta*pi)/sqrt(1-(cZeta^2)))*100;
sobrepaso=strcat(num2str(sp),'%');
disp(sobrepaso)
fprintf('\n')
%Tiempo de asentamiento
disp('Tiempo de asentamiento: ')
if ((cZeta>0) && (cZeta<0.69))
    tas=(3.2/(cZeta*cWn))
end
if (cZeta>0.69)
    tas=(4.53/cWn)
end
if(cZeta<0)
    disp('Si el amortiguamiento es negativo, no existe tiempo de asentamiento')
end
fprintf('\n');

%Errores de estado estable
disp('Error en estado estable:')
%Posicion
disp('Posicion:')
syms s
m=(poly2sym(val_us,s))/poly2sym(val_ys,s);
eep=(limit(m,s,0));
eep=double(eep)^-1
%Velocidad
disp('Velocidad: ')
eev=(limit(s*m,s,0));
eev=double(eev)^-1
%Aceleracion
disp('Aceleracion: ')
eea=(limit((s^2)*m,s,0));
eea=double(eea)^-1

%Estabilidad del sistema basado en K con retroalimentacion
syms k
sysNum=poly2sym(k*val_us,s);
sysDen=poly2sym(val_ys,s);
newSysDen=sysNum+sysDen;
eqCarac=flip(coeffs(newSysDen,s));

tablaRouth=routh.criterioRouth(eqCarac);
res=[];
for i=1:size(tablaRouth)
    valActual=tablaRouth(i,2);
    c=symvar(valActual);
    if (c==k)
        assume(k>0)
        kSol=solve(valActual,k);
        res=[res,vpa(kSol)];
    end
end
kRes=flip(res);
assume(k,'clear')
disp('Rango de estabilidad del sistema')
if(isempty(res))
    disp('No existen valores inestables para k')
elseif(kRes(1)==0)
    kEst=sprintf('El sistema es estable para k>0 & k<%0.3f',kRes(2))
    disp(kEst)
else
    kEst=sprintf('El sistema es estable para k>%0.3f',kRes(1))
    disp(kEst)
end
fprintf('\n')

%LGR
n=length(p);
m=length(z);
disp('Numero de ramas:')
disp(n)
nmAbs=abs(n-m);
asintotas=nmAbs;
disp('Numero de asintotas')
disp(asintotas)
sumPolos=0;
sumZeros=0;
for i=1:length(p)
    sumPolos=sumPolos+real(p(i));
end
for i=1:length(z)
    sumZeros=sumZeros+real(z(i));
end
if(asintotas>0)
    intersec=(sumPolos-sumZeros)/(n-m);
    disp('Puntos de interseccion:')
    disp(intersec)
else
    disp('No hay interseccion')
end
angulos=[];
for i=0:(nmAbs-1)
    pRup=((2*(i)+1)/nmAbs)*pi;
    angulos=[angulos,rad2deg(pRup)];
end
disp('Angulos:')
disp(angulos)

%Punto de ruptura
rupNum=poly2sym(val_us,s);
rupDen=poly2sym(val_ys,s);
derSys=(diff(rupDen)*rupNum)-(diff(rupNum)*rupDen);
polSys=flip(coeffs(expand(derSys)));
disp('Puntos de ruptura:')
disp(double(roots(polSys)))
 
%Graficas
figure;
subplot(2,2,1);
t=[0:0.1:20]';
step(val_us,val_ys);
xlim([0, 20]);
ylim([-5, 20]);
title('GRAFICA RESPECTO AL  ESCALON UNITARIO');
grid('on');
xlabel('t');
ylabel('Y');

subplot(2,2,2);
ramp = t;
yr = lsim(val_us,val_ys,ramp,t);
plot(t,yr,t,ramp);
ylim([-1, 20]);
title('GRAFICA RESPECTO A RAMPA');
grid;
xlabel('t');
ylabel('Y');

subplot(2,2,3);
pzmap(p,z);
title('POSICION EN EL PLANO DE POLOS Y CEROS');
xlabel('Reales');
ylabel('Imaginarios');

subplot(2,2,4);
rlocus(g);
title('LGR');
xlabel('Reales');
ylabel('Imaginarios');

figure;
bode(g);
clear
