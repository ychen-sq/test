function [p_flag0,p_flag1,p_flag2] = alertFlag_simp(date,hfindex)
    thrd_hf = 10;
    thrd_hf1 = 5;
    thrd0 = 100;
    thrd1 = 10;
    thrd2 = 5;
    thrd3 = 5;
    thrd4 = 2;
    len1 = 12;
    len2 = 6;
    len3 = 3;
    len4 = 1;

    hf_s = []; 
    hf_s(1) = hfindex(1);
    hf_g=[];hf_s_g=[];
        for j = 2:length(hfindex)
            date_num = datenum(date(j-1:j)); 
            hf_sx = hfindex(j-1:j);
            delt = diff(date_num)/30;
            delt_t(j-1)=delt;
            a = gradient(hf_sx,delt);
            hf_g(j-1) = a(1);
        end
        
        dex_flag = zeros(length(hf_g),1);
        for i = 1:length(hf_g)
            clear ds xx len dxx ixx
            dex_flag(i) = 0;  
            if i>1 && hf_g(i)==0 && dex_flag(i-1)>=1  
                dex_flag(i)=1;
                continue
            end
            if hf_g(i)>0 
                if i>1 && dex_flag(i-1)>=1
                    if hf_g(i)-hf_g(i-1)>thrd4
                        dex_flag(i)=1;
                    elseif hf_g(i)-hf_g(i-1)>thrd2
                        dex_flag(i)=2;
                    continue
                    end
                end
                
                if delt_t(i)<=len4
                    ds = date(i+1)-len4*30;
                    xx = find(date>=ds&date<date(i+1));
                    dxx = xx(xx>1)-1;
                    dxx = xx(hf_g(dxx)>0);
                    if hf_g(i)> thrd0
                        if hfindex(i+1)-hfindex(i)>=40
                            dex_flag(i) = -1;
                            continue
                        else
                            if isempty(dxx) 
                                if hf_g(i)> thrd1
                                    dex_flag(i) = 1;
                                    if hf_g(i)> thrd2
                                        dex_flag(i) = 2;
                                    end
                                end
                            else
                                if hf_g(i)> mean(hf_g(dxx))+thrd1 && hfindex(i+1)> mean(hfindex(xx))+thrd_hf1
                                    dex_flag(i) = 1;
                                    if hfindex(i+1)> mean(hfindex(xx))+thrd_hf
                                        dex_flag(i) = 2;
                                    end
                                else
                                    dex_flag(i) = -1;
                                end
                            end
                        end
                    else
                        if hf_g(i)> mean(hf_g(dxx))+thrd1 && hfindex(i+1)> mean(hfindex(xx))+thrd_hf1
                            dex_flag(i) = 1;
                            if hfindex(i+1)> mean(hfindex(xx))+thrd_hf
                                dex_flag(i) = 2;
                            end
                        end
                    end 
                elseif delt_t(i)>len4 && delt_t(i)<=len3
                    ds = date(i+1)-len3*30;
                    xx = date>=ds&date<date(i+1);
                    dxx = xx(xx>1)-1;
                    dxx = xx(hf_g(dxx)>0);
                    if isempty(dxx) 
                        if hf_g(i)> thrd1
                            dex_flag(i) = 1;
                            if hf_g(i)> thrd2
                                dex_flag(i) = 2;
                            end
                        end
                        if hf_g(i)> mean(hf_g(dxx))+thrd2 && hfindex(i+1)> mean(hfindex(xx))+thrd_hf1
                                dex_flag(i) = 1;
                            if hfindex(i+1)> mean(hfindex(xx))+thrd_hf
                                dex_flag(i) = 2;
                            end
                        end
                    end
                elseif delt_t(i)>len3 && delt_t(i)<=len2
                    ds = date(i+1)-len2*30;
                    xx = date>=ds&date<date(i+1);
                    dxx = xx(xx>1)-1;
                    dxx = xx(hf_g(dxx)>0);
                    if isempty(dxx) 
                        if hf_g(i)> thrd1
                            dex_flag(i) = 1;
                            if hf_g(i)> thrd2
                                dex_flag(i) = 2;
                            end
                        end
                        if hf_g(i)> mean(hf_g(dxx))+thrd3 && hfindex(i+1)> mean(hfindex(xx))+thrd_hf1
                                dex_flag(i) = 1;
                            if hfindex(i+1)> mean(hfindex(xx))+thrd_hf
                                dex_flag(i) = 2;
                            end
                        end  
                    end
                elseif delt_t(i)>len2 && delt_t(i)<=len1
                    ds = date(i+1)-len1*30;
                    xx = date>=ds&date<date(i+1);
                    dxx = xx(xx>1)-1;
                    dxx = xx(hf_g(dxx)>0);
                    if isempty(dxx) 
                        if hf_g(i)> thrd1
                            dex_flag(i) = 1;
                            if hf_g(i)> thrd2
                                dex_flag(i) = 2;
                            end
                        end
                        if hf_g(i)> mean(hf_g(dxx))+thrd4 && hfindex(i+1)> mean(hfindex(xx))+thrd_hf1
                                dex_flag(i) = 1;
                            if hfindex(i+1)> mean(hfindex(xx))+thrd_hf
                                dex_flag(i) = 2;
                            end
                        end
                    end
                else
                    if hfindex(i+1)-hfindex(i)>=20
                            dex_flag(i) = 1;
                    elseif hfindex(i+1)-hfindex(i)>=30
                            dex_flag(i) = 2;
                    end
                end
            end
        end       
        p_flag2 = find(dex_flag==2);
        p_flag1 = find(dex_flag==1);
        p_flag0 = find(dex_flag==-1);
end