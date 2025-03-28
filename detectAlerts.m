function [alert1_flag, alert2_flag] = detectAlerts(dates, hfindex)
%detectAlerts 時系列データからAlert1（短期的な急激な変化）とAlert2（長期的な悪化傾向）を検知する関数。
%
%   [alert1_flag, alert2_flag] = detectAlerts(dates, hfindex)
%
%   入力：
%       dates   : 日付のベクトル（datetime型）
%       hfindex : 時系列データのベクトル（double型）
%
%   出力：
%       alert1_flag : Alert1が検知された場合1、それ以外は0
%       alert2_flag : Alert2が検知された場合1、それ以外は0

% パラメータ設定（調整可能）
x = 0.1;       % Alert1の閾値（変化率、10%）
y = 0.05;       % Alert2の閾値（変化率、5%）
z = 25;         % ベースラインの閾値（hfindexのベースライン）
alert1_baseline_days = 14; % Alert1のベースライン期間
alert2_baseline_days = 30; % Alert2のベースライン期間
moving_average_window = 7;  % 移動平均の窓幅
hampel_window = 7; % ハンペルフィルタの窓幅

% 初期化
alert1_flag = 0;
alert2_flag = 0;

% 1. 前処理

%   ・日付ごとに平均 hfindex を計算 (NaNを無視)
[unique_dates, ~, date_indices] = unique(dates);
averaged_hfindex = accumarray(date_indices, hfindex, [], @(x) mean(x, 'omitnan'));

%   ・連続日付の生成とNaN補完
expected_dates = unique_dates(1):unique_dates(end);
[~, expected_indices] = ismember(unique_dates,expected_dates);
filled_hfindex = NaN(size(expected_dates));
filled_hfindex(expected_indices) = averaged_hfindex;


%   ・ハンペルフィルタで外れ値を除去
hfindex_filtered = hampel(filled_hfindex, hampel_window);

%   ・移動平均フィルタで平滑化
hfindex_smoothed = movmean(hfindex_filtered, moving_average_window, 'omitnan');


hf = hfindex_smoothed(expected_indices);
hf_g = NaN(length(expected_indices),1);
for j = 2:length(hf_g)
    date_num = datenum(unique_dates(j-1:j)); 
    hf_sx = hf(j-1:j);
    delt = diff(date_num)/30;
    a = gradient(hf_sx,delt);
    hf_g(j) = a(1);
end
hf_gradient = NaN(length(hfindex_smoothed),1);
hf_gradient(expected_indices) = hf_g;

% 2. Alert 1 の検知

%   ・ベースラインデータ取得
baseline_start_date = expected_dates(end) - caldays(alert1_baseline_days);
baseline_end_date = expected_dates(end) - caldays(1);

baseline_indices = expected_dates >= baseline_start_date & expected_dates <= baseline_end_date;
baseline_data = hf_gradient(baseline_indices);


%   ・比較対象: 直近のベースラインと過去2日間のデータ
comparison_start_date = expected_dates(end) - caldays(2);
comparison_end_date = expected_dates(end);
comparison_indices = expected_dates >= comparison_start_date & expected_dates <= comparison_end_date;
comparison_data = hf_gradient(comparison_indices);


%   ・トリガー条件: 事前設定した変化率 x% を超える急激な変化 (増加する場合のみ)
if ~isempty(baseline_data) && ~isempty(comparison_data)
    % NaNの除去
    baseline_data = baseline_data(~isnan(baseline_data));
    comparison_data = comparison_data(~isnan(comparison_data));

    if ~isempty(baseline_data) && ~isempty(comparison_data)
      % 勾配の計算
      baseline_gradient = mean(baseline_data);
      comparison_gradient = mean(comparison_data);

      % 変化率の計算
      change_rate = (comparison_gradient - baseline_gradient) / abs(baseline_gradient);

      % 比較対象の平均値がzより高いか確認
      if mean(hfindex_smoothed(comparison_indices)) > z
          % アラート判定: 変化率が正（増加）かつ閾値を超える場合のみ
          if ~isinf(change_rate) && change_rate > x && comparison_gradient > 0
              alert1_flag = 1;
          end
      end
    end
end



% 3. Alert 2 の検知

%   ・ベースラインデータ取得
baseline_start_date_long = expected_dates(end) - caldays(alert2_baseline_days);
baseline_end_date_long = expected_dates(end) - caldays(1);

baseline_indices_long = expected_dates >= baseline_start_date_long & expected_dates <= baseline_end_date_long;
baseline_data_long = hf_gradient(baseline_indices_long);

%   ・移動平均計算: 直近7日間の移動平均を算出 (前処理で実施済)

%   ・トリガー条件: 1週間にわたり悪化傾向が継続、直近の移動平均と長期ベースラインの比較、 変化率がy% 以上の変化 (増加する場合のみ)
last_week_start_date = expected_dates(end) - caldays(7);
last_week_end_date = expected_dates(end);
last_week_indices = expected_dates >= last_week_start_date & expected_dates <= last_week_end_date;
last_week_data = hf_gradient(last_week_indices);

if ~isempty(baseline_data_long) && ~isempty(last_week_data)
    % NaNの除去
    baseline_data_long = baseline_data_long(~isnan(baseline_data_long));
    last_week_data = last_week_data(~isnan(last_week_data));

    if ~isempty(baseline_data_long) && ~isempty(last_week_data)
      % 勾配の計算
      baseline_gradient_long = mean(gradient(baseline_data_long));
      last_week_gradient = mean(gradient(last_week_data));

      % 変化率の計算
      change_rate_long = (last_week_gradient - baseline_gradient_long) / abs(baseline_gradient_long);

      % 比較対象の平均値がzより高いか確認
      if mean(last_week_data) > z
          % アラート判定: 変化率が正（増加）かつ閾値を超える場合のみ
          if ~isinf(change_rate_long) && change_rate_long > y && last_week_gradient > 0
              alert2_flag = 1;
          end
      end
    end
end

end