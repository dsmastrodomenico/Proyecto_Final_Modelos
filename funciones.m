classdef funciones
    methods(Static)
        function[g,ceros,polos,ganancia]=fTransfer(num,den)
            %zpk
            [z,p,k]=tf2zp(num,den);
            %tf
            g=tf(num,den)
            
            if(isempty(z))
                ceros='No hay ceros';
            else
                ceros=z
            end
            polos=p
            ganancia=k
        end
        function est=estabilidad(p)
            for i=1 : length(p)
                if(p(i)>0)
                    est='Este sistema es inestable.'
                    break;
                end
                if(i==length(p))
                    est='Este sistema es estable'
                    break;
                end
            end
        end
        function amor=amortiguamiento(g)
            %Amortiguamiento
            [wn,zeta]=damp(g);
            cZeta=zeta(1);
            amor='';
            if(cZeta==1)
                amor='El sistema tiene amortiguamiento critico ';
            elseif(cZeta==0)
                amor='El sistema es no amortiguado';
            elseif(cZeta>1)
                amor='El sistema es sobreamortiguado';
            elseif((cZeta>0) && (cZeta<1))
                amor='El sistema esta bajo amortiguamiento';
            elseif(cZeta<0)
                amor='El sistema tiene amortiguamiento negativo';
            end
            amor
        end
        function sobrepaso=sobrepaso(g)
            %Sobrepaso
            [wn,zeta]=damp(g);
            cZeta=zeta(1);
            sp=exp((-cZeta*pi)/sqrt(1-(cZeta^2)))*100;
            sobrepaso=strcat(num2str(sp),'%');
            sobrepaso
        end
        function tWn=coeficienteWn(g)
            %Tiempo de asentamiento
            [wn,zeta]=damp(g);
            tWn=wn(2);
        end
        function tZeta=coeficientezeta(g)
            %Tiempo de asentamiento
            [wn,zeta]=damp(g);
            tZeta=zeta(2);
        end

        
        
        function tas=tAsentamiento(g)
            %Tiempo de asentamiento
            [wn,zeta]=damp(g);
            cWn=wn(1);
            cZeta=zeta(1);
            if ((cZeta>0) && (cZeta<0.69))
                tas=(3.2/(cZeta*cWn));
                num2str(tas)
            end
            if (cZeta>0.69)
                tas=(4.53/cWn);
                num2str(tas)
            end
            if(cZeta<0)
                tas='Si el amortiguamiento es negativo no existe tiempo de asentamiento';
            end
        end
        function [eep,eev,eea]=errores(num,den)
            %Posicion
            disp('Posicion:')
            syms s
            m=(poly2sym(num,s))/poly2sym(den,s);
            eep=(limit(m,s,0));
            eep=num2str(double(eep)^-1)
            %Velocidad
            disp('Velocidad: ')
            eev=(limit(s*m,s,0));
            eev=num2str(double(eev)^-1)
            %Aceleracion
            disp('Aceleracion: ')
            eea=(limit((s^2)*m,s,0));
            eea=num2str(double(eea)^-1)
        end
        function kEst=estabilidadK(num,den)
            %Estabilidad del sistema basado en K con retroalimentacion
            syms k
            syms s
            sysNum=poly2sym(k*num,s);
            sysDen=poly2sym(den,s);
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
            if(isempty(res))
                kEst='No existen valores inestables para k'
            elseif(kRes(1)==0)
                kEst=sprintf('El sistema es estable para k>0 & k<%0.3f',kRes(2));
                kEst
            else
                kEst=sprintf('El sistema es estable para k>%0.3f',kRes(1));
                kEst
            end
        end
        function [ram,asint,inter,ang]=LGR(p,z)
            %LGR
            n=length(p)
            m=length(z);
            %ramas
            ram=num2str(n)
            nmAbs=abs(n-m);
            %asintotas
            asint=num2str(nmAbs)
            sumPolos=0;
            sumZeros=0;
            for i=1:length(p)
                sumPolos=sumPolos+real(p(i));
            end
            for i=1:length(z)
                sumZeros=sumZeros+real(z(i));
            end
            if(asint>0)
                %Puntos de interseccion:
                intersec=(sumPolos-sumZeros)/(n-m);
                inter=num2str(intersec)
            else
                inter='No hay interseccion';
            end
            angulos=[];
            for i=0:(nmAbs-1)
                pRup=((2*(i)+1)/nmAbs)*pi;
                angulos=[angulos,rad2deg(pRup)];
            end
            ang=angulos
        end
        function rP=pRuptura(num,den)
            %Punto de ruptura
            syms s
            rupNum=poly2sym(num,s);
            rupDen=poly2sym(den,s);
            derSys=(diff(rupDen)*rupNum)-(diff(rupNum)*rupDen);
            polSys=flip(coeffs(expand(derSys)));
            rP=double(roots(polSys))
        end
    end
end